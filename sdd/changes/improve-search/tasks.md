# Tasks: Mejora de la Búsqueda de Productos

## Phase 1: Infraestructura y Dependencias

- [x] 1.1 Modificar `Gemfile` para agregar `gem 'pg_search'`.
- [x] 1.2 Ejecutar `bundle install` para instalar la gema.
- [x] 1.3 Crear una nueva migración con `bin/rails generate migration EnablePgSearchExtensions`.
- [x] 1.4 Editar la migración creada para incluir `enable_extension 'pg_trgm'` y `enable_extension 'unaccent'`.
- [x] 1.5 Ejecutar `bin/rails db:migrate` para aplicar la migración a la base de datos local.

## Phase 2: Implementación de la Búsqueda

- [x] 2.1 En `app/models/producto.rb`, incluir el módulo `PgSearch::Model`.
- [x] 2.2 En `app/models/producto.rb`, eliminar la implementación actual del scope `buscar`.
- [x] 2.3 En `app/models/producto.rb`, agregar la nueva definición de `pg_search_scope :buscar` configurando `against`, `associated_against: { categoria: :nombre }`, y `using: { tsearch: { any_word: true, unaccent: true, prefix: true }, trigram: { word_similarity: true } }`.

## Phase 3: Verificación

- [x] 3.1 Ejecutar `bin/rails test` para asegurar que todas las pruebas existentes de la aplicación pasen con el nuevo modelo de búsqueda.
- [x] 3.2 Probar manualmente levantando el servidor Rails para confirmar que el controlador `ProductosController` y las sugerencias del front-end funcionan correctamente con los cambios implementados.