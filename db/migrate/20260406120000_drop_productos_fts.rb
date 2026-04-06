class DropProductosFts < ActiveRecord::Migration[8.1]
  def up
    execute "DROP TRIGGER IF EXISTS productos_au"
    execute "DROP TRIGGER IF EXISTS productos_ad"
    execute "DROP TRIGGER IF EXISTS productos_ai"
    drop_table :productos_fts, if_exists: true
  end

  def down
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
        VALUES (new.id, new.nombre, new.descripcion,
          (SELECT nombre FROM categorias WHERE id = new.categoria_id));
      END;

      CREATE TRIGGER productos_ad AFTER DELETE ON productos BEGIN
        INSERT INTO productos_fts(productos_fts, rowid, nombre, descripcion, categoria)
        VALUES ('delete', old.id, old.nombre, old.descripcion,
          (SELECT nombre FROM categorias WHERE id = old.categoria_id));
      END;

      CREATE TRIGGER productos_au AFTER UPDATE ON productos BEGIN
        INSERT INTO productos_fts(productos_fts, rowid, nombre, descripcion, categoria)
        VALUES ('delete', old.id, old.nombre, old.descripcion,
          (SELECT nombre FROM categorias WHERE id = old.categoria_id));
        INSERT INTO productos_fts(rowid, nombre, descripcion, categoria)
        VALUES (new.id, new.nombre, new.descripcion,
          (SELECT nombre FROM categorias WHERE id = new.categoria_id));
      END;
    SQL
  end
end
