# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_30_010000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categorias", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nombre", null: false
    t.string "prefijo", limit: 10
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_categorias_on_nombre", unique: true
    t.index ["prefijo"], name: "index_categorias_on_prefijo", unique: true
  end

  create_table "ia_usages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ia_service", null: false
    t.date "last_reset_date", default: -> { "CURRENT_DATE" }
    t.integer "last_reset_month", default: 1
    t.integer "requests_this_month", default: 0
    t.integer "requests_today", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "ia_service"], name: "index_ia_usages_on_user_id_and_ia_service", unique: true
  end

  create_table "notas", force: :cascade do |t|
    t.text "contenido", limit: 1000
    t.datetime "created_at", null: false
    t.integer "producto_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["producto_id", "created_at"], name: "index_notas_on_producto_id_and_created_at"
    t.index ["producto_id"], name: "index_notas_on_producto_id"
    t.index ["user_id", "created_at"], name: "index_notas_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_notas_on_user_id"
  end

  create_table "producto_historiales", force: :cascade do |t|
    t.string "campo"
    t.datetime "created_at"
    t.integer "producto_id", null: false
    t.text "resumen"
    t.integer "user_id", null: false
    t.text "valor_anterior"
    t.text "valor_nuevo"
    t.index ["producto_id", "created_at"], name: "index_producto_historiales_on_producto_id_and_created_at"
    t.index ["producto_id"], name: "index_producto_historiales_on_producto_id"
    t.index ["user_id"], name: "index_producto_historiales_on_user_id"
  end

  create_table "producto_vistos", force: :cascade do |t|
    t.integer "producto_id", null: false
    t.integer "user_id", null: false
    t.datetime "visto_at"
    t.index ["producto_id", "visto_at"], name: "index_producto_vistos_on_producto_id_and_visto_at"
    t.index ["producto_id"], name: "index_producto_vistos_on_producto_id"
    t.index ["user_id", "producto_id"], name: "index_producto_vistos_on_user_id_and_producto_id", unique: true
    t.index ["user_id", "visto_at"], name: "index_producto_vistos_on_user_id_and_visto_at"
    t.index ["user_id"], name: "index_producto_vistos_on_user_id"
  end

  create_table "productos", force: :cascade do |t|
    t.integer "categoria_id", null: false
    t.string "codigo", limit: 20
    t.datetime "created_at", null: false
    t.text "descripcion", null: false
    t.text "embedding"
    t.integer "estado", null: false
    t.integer "etiqueta", default: 0
    t.integer "last_updated_by_id"
    t.string "nombre", null: false
    t.decimal "precio_compra", precision: 10, scale: 2, null: false
    t.decimal "precio_venta", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["categoria_id", "created_at"], name: "index_productos_on_categoria_id_and_created_at"
    t.index ["categoria_id"], name: "index_productos_on_categoria_id"
    t.index ["codigo"], name: "index_productos_on_codigo", unique: true
    t.index ["estado", "created_at"], name: "index_productos_on_estado_and_created_at"
    t.index ["estado"], name: "index_productos_on_estado"
    t.index ["etiqueta"], name: "index_productos_on_etiqueta"
    t.index ["last_updated_by_id"], name: "index_productos_on_last_updated_by_id"
    t.index ["user_id", "created_at"], name: "index_productos_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_productos_on_user_id"
  end

  create_table "productos_fts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "api_key"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "gemini_model", default: "gemini-2.5-flash"
    t.string "ia_service", default: "gemini"
    t.string "moondream_mode", default: "cloud"
    t.string "nombre", null: false
    t.string "password_digest", null: false
    t.integer "rol", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ia_usages", "users"
  add_foreign_key "notas", "productos", on_delete: :cascade
  add_foreign_key "notas", "users", on_delete: :cascade
  add_foreign_key "producto_historiales", "productos", on_delete: :cascade
  add_foreign_key "producto_historiales", "users", on_delete: :nullify
  add_foreign_key "producto_vistos", "productos", on_delete: :cascade
  add_foreign_key "producto_vistos", "users", on_delete: :cascade
  add_foreign_key "productos", "users"
  add_foreign_key "productos", "users", column: "last_updated_by_id"
  add_foreign_key "sessions", "users"
end
