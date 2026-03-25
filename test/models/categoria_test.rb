require "test_helper"

class CategoriaTest < ActiveSupport::TestCase
  test "requires nombre" do
    categoria = Categoria.new
    assert_not categoria.valid?
    assert_includes categoria.errors[:nombre], "no puede estar en blanco"
  end

  test "enforces uniqueness of nombre" do
    categoria = Categoria.new(nombre: categorias(:muebles).nombre)
    assert_not categoria.valid?
    assert_includes categoria.errors[:nombre], "ya está en uso"
  end

  test "enforces case-insensitive uniqueness" do
    categoria = Categoria.new(nombre: "muebles")
    assert_not categoria.valid?
    assert_includes categoria.errors[:nombre], "ya está en uso"
  end

  test "restricts deletion when has productos" do
    categoria = categorias(:muebles)
    categoria.productos.create!(
      nombre: "Test",
      descripcion: "Test desc",
      precio_compra: 10,
      precio_venta: 20,
      estado: :nuevo,
      user: users(:one)
    )
    assert_no_difference("Categoria.count") do
      categoria.destroy
    end
  end
end
