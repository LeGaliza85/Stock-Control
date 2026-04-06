# Design: Mejora de la Búsqueda de Productos

## Technical Approach

La solución utiliza `pg_search` que provee una abstracción potente sobre las características de búsqueda nativas de PostgreSQL. Habilitaremos `pg_trgm` para la similitud de cadenas y `unaccent` para ignorar tildes. Configuraremos el modelo `Producto` usando el bloque `pg_search_scope`.

## Architecture Decisions

### Decision: Database Native Search vs External Engine

**Choice**: PostgreSQL Text Search (`pg_search`)
**Alternatives considered**: Elasticsearch, Algolia, Meilisearch
**Rationale**: Mantener una arquitectura sencilla (Standard Rails MVC). No necesitamos la complejidad operativa de mantener Elasticsearch para el tamaño actual del catálogo. Postgres maneja el full-text search de forma nativa e integrada.

### Decision: Extensiones Postgres

**Choice**: `pg_trgm` y `unaccent`
**Alternatives considered**: Usar solo `tsearch` o expresiones regulares.
**Rationale**: `tsearch` soporta "stemming" y diccionarios, pero `pg_trgm` es indispensable para búsquedas "fuzzy" (errores tipográficos). `unaccent` es necesario para el idioma español debido al uso constante de tildes.

## Data Flow

    [Frontend/Stimulus] --> [ProductosController#index / #suggestions]
                             |
                             | llama a params[:query]
                             v
                        [Producto.buscar("término")]
                             |
                             | pg_search traduce a SQL tsvector/trigrams
                             v
                        [PostgreSQL]

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `Gemfile` | Modify | Agregar gem 'pg_search' |
| `db/migrate/xxx_enable_pg_extensions.rb` | Create | Habilitar `pg_trgm` y `unaccent` |
| `app/models/producto.rb` | Modify | Quitar scope antiguo y agregar `pg_search_scope :buscar` |

## Interfaces / Contracts

El contrato de la interfaz se mantiene intacto. El controlador seguirá invocando `Producto.buscar(termino)`. El scope debe seguir devolviendo un `ActiveRecord::Relation` que puede ser encadenado con otras condiciones (e.g., `left_joins(:categoria)` si es necesario, o `pg_search` lo maneja con `associated_against`).

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | `Producto.buscar` | Verificar que la búsqueda coincida con texto con tildes y errores leves. |
| Integration | `ProductosController` | Confirmar que los endpoints responden 200 y filtran correctamente. |

## Migration / Rollout

La migración de DB habilitará las extensiones.
`bin/rails db:migrate`

## Open Questions

- [ ] Si los trigramas son lentos en producción por tamaño de tabla, ¿debemos agregar un índice `gin` sobre los campos en una migración posterior? (Se recomienda observar primero).