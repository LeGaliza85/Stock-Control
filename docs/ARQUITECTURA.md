# Documentación Técnica - Arquitectura
## StockControl App

---

## 1. Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                    NAVEGADOR (HTML + Turbo)                  │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ Turbo    │  │ Turbo    │  │ Stimulus  │  │ File       │  │
│  │ Drive    │  │ Frames   │  │ JS        │  │ Upload     │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP
               ┌───────┴────────┐
               │  Rails 8 App   │
               │                │
               │ · Hotwire      │
               │ · Active Store │
               │ · Auth (built) │
               │ · FTS5 Search  │
               │ · libvips      │
               └───────┬────────┘
                       │
               ┌───────┴────────┐
               │    SQLite3     │
               └────────────────┘
```

---

## 2. Estructura de Proyecto

```
stockcontrol/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── registrations_controller.rb
│   │   ├── productos_controller.rb
│   │   └── settings_controller.rb
│   │
│   ├── models/
│   │   ├── application_record.rb
│   │   ├── user.rb
│   │   ├── producto.rb
│   │   └── current.rb
│   │
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb
│   │   ├── sessions/
│   │   │   └── new.html.erb
│   │   ├── registrations/
│   │   │   └── new.html.erb
│   │   ├── productos/
│   │   │   ├── index.html.erb
│   │   │   ├── show.html.erb
│   │   │   ├── new.html.erb
│   │   │   ├── edit.html.erb
│   │   │   └── _form.html.erb
│   │   └── settings/
│   │       └── show.html.erb
│   │
│   ├── javascript/
│   │   ├── application.js
│   │   └── controllers/          # Stimulus controllers
│   │
│   └── assets/
│       └── stylesheets/
│           └── application.css
│
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── storage.yml
│
├── db/
│   ├── migrate/
│   └── schema.rb
│
├── storage/                      # Active Storage (disco local)
│
├── Dockerfile.dev
├── docker-compose.yml
├── Gemfile
└── Gemfile.lock
```

---

## 3. Esquema de Base de Datos

### Migraciones Rails

```ruby
# db/migrate/xxx_create_users.rb
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :nombre, null: false
      t.string :password_digest, null: false
      t.integer :rol, default: 0, null: false  # enum: miembro, admin

      t.timestamps
    end

    add_index :users, :email_address, unique: true
  end
end

# db/migrate/xxx_create_productos.rb
class CreateProductos < ActiveRecord::Migration[8.0]
  def change
    create_table :productos do |t|
      t.string :nombre, null: false
      t.text :descripcion, null: false
      t.decimal :precio_compra, precision: 10, scale: 2, null: false
      t.decimal :precio_venta, precision: 10, scale: 2, null: false
      t.integer :estado, null: false          # enum: nuevo, bueno, aceptable, desgastado, reparacion
      t.integer :año_aprox
      t.string :uso
      t.string :categoria, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :productos, :categoria
    add_index :productos, :estado
  end
end
```

### FTS5 (Full-Text Search)

```ruby
# db/migrate/xxx_create_productos_fts.rb
class CreateProductosFts < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE VIRTUAL TABLE productos_fts USING fts5(
        nombre,
        descripcion,
        categoria,
        content='productos',
        content_rowid='id'
      );

      CREATE TRIGGER productos_ai AFTER INSERT ON productos BEGIN
        INSERT INTO productos_fts(rowid, nombre, descripcion, categoria)
        VALUES (new.id, new.nombre, new.descripcion, new.categoria);
      END;

      CREATE TRIGGER productos_ad AFTER DELETE ON productos BEGIN
        INSERT INTO productos_fts(productos_fts, rowid, nombre, descripcion, categoria)
        VALUES ('delete', old.id, old.nombre, old.descripcion, old.categoria);
      END;

      CREATE TRIGGER productos_au AFTER UPDATE ON productos BEGIN
        INSERT INTO productos_fts(productos_fts, rowid, nombre, descripcion, categoria)
        VALUES ('delete', old.id, old.nombre, old.descripcion, old.categoria);
        INSERT INTO productos_fts(rowid, nombre, descripcion, categoria)
        VALUES (new.id, new.nombre, new.descripcion, new.categoria);
      END;
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS productos_fts"
  end
end
```

---

## 4. Modelos

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :productos

  enum :rol, { miembro: 0, admin: 1 }

  normalizes :email_address, with: -> { _1.strip.downcase }
end

# app/models/producto.rb
class Producto < ApplicationRecord
  belongs_to :user
  has_many_attached :fotos

  enum :estado, {
    nuevo: 0,
    bueno: 1,
    aceptable: 2,
    desgastado: 3,
    reparacion: 4
  }

  validates :nombre, :descripcion, :precio_compra, :precio_venta,
            :estado, :categoria, presence: true

  scope :buscar, ->(termino) {
    where("id IN (SELECT rowid FROM productos_fts WHERE productos_fts MATCH ?)", termino)
  }
end
```

---

## 5. Rutas

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resource :registration, only: [:new, :create]

  resources :productos

  resource :settings, only: [:show, :update]

  root "productos#index"
end
```

---

## 6. Flujos de Usuario

### Crear producto con foto

```
Usuario pulsa "Nuevo producto"
    │
    ▼
Formulario con campos + input de fotos
    │
    ▼
Selecciona fotos desde dispositivo
    │
    ▼
Completa datos: nombre, precio, estado, categoría...
    │
    ▼
Submit → Rails guarda producto + Active Storage procesa fotos
    │
    ▼
Redirect al detalle del producto con Turbo Drive
```

### Búsqueda de producto

```
Usuario escribe en buscador
    │
    ▼
Turbo Frame envía petición al servidor
    │
    ▼
SQLite FTS5 busca en nombre + descripción + categoría
    │
    ▼
Resultados renderizados en el frame
    │
    ▼
Filtrar por: categoría, estado, rango de precios
```

---

## 7. Dependencias

```ruby
# Gemfile
gem "rails", "~> 8.0"
gem "sqlite3"
gem "puma"
gem "propshaft"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bcrypt"
gem "image_processing", "~> 1.2"
gem "solid_cache"
gem "solid_queue"
```

---

## 8. Variables de Entorno

```env
RAILS_ENV=production
SECRET_KEY_BASE=xxxxx
```

---

## 9. Decisiones Técnicas

| Decisión | Razón |
|----------|-------|
| Rails 8 monolito | Máxima simplicidad, SSR, sin API separada |
| SQLite3 | Sin dependencias externas, perfecto para equipo pequeño |
| Hotwire (Turbo + Stimulus) | Interactividad sin SPA, menos JS, más productividad |
| Active Storage local | Fotos en disco, sin dependencia de servicios cloud |
| FTS5 | Búsqueda full-text nativa de SQLite, sin servicios externos |
| Docker Compose | Entorno reproducible con un solo comando |
| Auth built-in de Rails 8 | Sin gemas externas (Devise), menos complejidad |
