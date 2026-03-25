require "test_helper"

class CategoriasControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(User.take) }

  test "index" do
    get categorias_path
    assert_response :success
  end

  test "new" do
    get new_categoria_path
    assert_response :success
  end

  test "create" do
    assert_difference("Categoria.count") do
      post categorias_path, params: { categoria: { nombre: "Nueva Categoría" } }
    end
    assert_redirected_to categorias_path
  end

  test "create with invalid params" do
    assert_no_difference("Categoria.count") do
      post categorias_path, params: { categoria: { nombre: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "edit" do
    categoria = categorias(:muebles)
    get edit_categoria_path(categoria)
    assert_response :success
  end

  test "update" do
    categoria = categorias(:muebles)
    patch categoria_path(categoria), params: { categoria: { nombre: "Muebles Actualizados" } }
    assert_redirected_to categorias_path
    assert_equal "Muebles Actualizados", categoria.reload.nombre
  end

  test "destroy when no productos" do
    categoria = categorias(:arte)
    assert_difference("Categoria.count", -1) do
      delete categoria_path(categoria)
    end
    assert_redirected_to categorias_path
  end

  test "destroy when has productos" do
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
      delete categoria_path(categoria)
    end
    assert_redirected_to categorias_path
  end
end
