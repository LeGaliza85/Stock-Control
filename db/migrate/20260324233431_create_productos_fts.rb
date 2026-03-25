class CreateProductosFts < ActiveRecord::Migration[8.1]
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
    execute <<-SQL
      DROP TRIGGER IF EXISTS productos_au;
      DROP TRIGGER IF EXISTS productos_ad;
      DROP TRIGGER IF EXISTS productos_ai;
      DROP TABLE IF EXISTS productos_fts;
    SQL
  end
end
