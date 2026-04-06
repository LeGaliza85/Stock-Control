# Proposal: Mejora de la Búsqueda de Productos

## Intent

La búsqueda actual de productos (`Producto.buscar`) utiliza múltiples cláusulas `LIKE` con uniones `OR`, dividiendo manualmente los términos de búsqueda. Esto es rígido, no es tolerante a errores tipográficos ("fuzzy") y no maneja acentos de manera robusta. Queremos proporcionar a los usuarios una búsqueda rápida y flexible que ofrezca resultados relevantes incluso si cometen pequeños errores al escribir o no usan tildes.

## Scope

### In Scope
- Implementar la gema `pg_search` en el modelo `Producto`.
- Configurar PostgreSQL con extensiones `pg_trgm` y `unaccent`.
- Reemplazar el scope `buscar` actual en `Producto` por un `pg_search_scope`.
- Mantener compatibilidad con los controladores existentes (`ProductosController#index` y `#suggestions`).

### Out of Scope
- Reemplazar la búsqueda por embeddings/similitud de imágenes.
- Implementar motores de búsqueda externos como Elasticsearch o Algolia.

## Approach

Reemplazaremos el método manual `scope :buscar` con el método nativo proporcionado por la gema `pg_search`. Activaremos las extensiones `pg_trgm` (para búsqueda fuzzy y similitud de palabras) y `unaccent` (para ignorar acentos de forma nativa) a través de una migración en PostgreSQL. Esto mejorará significativamente el rendimiento y la precisión de la búsqueda de texto.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `Gemfile` | Modified | Añadir gema `pg_search` |
| `db/migrate/` | New | Migración para `pg_trgm` y `unaccent` |
| `app/models/producto.rb` | Modified | Reemplazar lógica de búsqueda |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Incompatibilidad de base de datos | Low | `pg_trgm` y `unaccent` son estándar en PostgreSQL, las migraciones se encargarán de habilitarlas. |
| Rendimiento sin índices | Medium | Las tablas actuales son pequeñas. Si crecen, agregaremos índices GIN para optimizar pg_search. |

## Rollback Plan

1. Revertir la migración de base de datos usando `bin/rails db:rollback`.
2. Deshacer el commit que añade `pg_search` y reinstaura el antiguo scope `buscar` en `Producto`.
3. Ejecutar `bundle install` para actualizar el `Gemfile.lock`.

## Dependencies

- PostgreSQL debe permitir la habilitación de extensiones (`SUPERUSER` no suele ser necesario si la base de datos es de un usuario normal en entornos modernos, pero debe revisarse en producción).

## Success Criteria

- [ ] Las pruebas locales pasan sin modificaciones significativas (si mockean búsqueda de texto, adaptarlas).
- [ ] La búsqueda ignora acentos (e.g., buscar "arbol" encuentra "árbol").
- [ ] La búsqueda es tolerante a faltas leves gracias a los trigramas.