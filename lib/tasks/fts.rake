namespace :fts do
  desc "Rebuild FTS5 index for productos"
  task rebuild: :environment do
    conn = ActiveRecord::Base.connection.raw_connection
    conn.execute("DELETE FROM productos_fts")
    conn.execute("INSERT INTO productos_fts(rowid, nombre, descripcion, categoria) SELECT id, nombre, descripcion, categoria FROM productos")
    count = conn.execute("SELECT count(*) FROM productos_fts").first["count(*)"]
    puts "FTS5 index rebuilt: #{count} rows"
  end
end
