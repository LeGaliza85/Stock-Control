require "test_helper"

class ProductosFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "can view index" do
    get productos_path
    assert_response :success
  end

  test "can view show" do
    producto = productos(:one)
    get producto_path(producto)
    assert_response :success
  end

  test "can view new" do
    get new_producto_path
    assert_response :success
  end

  test "can create producto" do
    assert_difference("Producto.count") do
      post productos_path, params: {
        producto: {
          nombre: "Nuevo Test",
          descripcion: "Desc",
          precio_compra: 10,
          precio_venta: 20,
          estado: "nuevo",
          categoria_id: categorias(:muebles).id,
          etiqueta: "en_venta"
        }
      }
    end
    assert_redirected_to producto_path(Producto.last)
  end

  test "can update producto" do
    producto = productos(:one)
    patch producto_path(producto), params: {
      producto: { nombre: "Actualizado" }
    }
    assert_redirected_to producto_path(producto)
    assert_equal "Actualizado", producto.reload.nombre
  end
end
