# Plan de Refactorización - StockControl

> Análisis completo del código y plan de mejoras incrementales

---

## Estado Actual

| Métrica | Valor |
|---------|-------|
| Controladores | 11 archivos (1,078 líneas totales) |
| Vistas | 21 archivos (3,178 líneas totales) |
| Modelos | 11 archivos (~560 líneas totales) |
| JS inline en vistas | **1,217 líneas** (38.3% del total de vistas) |
| Stimulus controllers existentes | 8 (pocos usados) |
| Service objects | 1 (`ImageAnalyzerService`, 543 líneas) |
| Tests | Existen pero no se han verificado |

---

## FASE 0: Seguridad (URGENTE)

### 0.1 Contraseña admin hardcoded

**Archivo:** `app/controllers/usuarios_controller.rb`
**Líneas:** 165, 199

```ruby
# ANTES (CRÍTICO)
unless params[:admin_password] == "Admin123"

# DESPUÉS
unless params[:admin_password] == ENV["ADMIN_SWITCH_PASSWORD"]
```

**Acción:** Mover a variable de entorno `ADMIN_SWITCH_PASSWORD` en `.env`

---

### 0.2 Fallback a User.first sin sesión

**Archivo:** `app/controllers/usuarios_controller.rb`
**Línea:** 28

```ruby
# ANTES (CRÍTICO - si no hay sesión, usa el primer usuario = admin)
@current_user = Current.user || User.first

# DESPUÉS
return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless Current.user
@current_user = Current.user
```

---

### 0.3 Sin autorización en Categorías CRUD

**Archivo:** `app/controllers/categorias_controller.rb`

Cualquier usuario autenticado puede crear, editar y eliminar categorías.

```ruby
# AÑADIR
before_action :require_no_visitante, only: [:new, :create, :edit, :update, :destroy, :quick_create]
```

---

### 0.4 Sin autorización en Notas update/destroy

**Archivo:** `app/controllers/notas_controller.rb`
**Líneas:** 17-31

Cualquier usuario puede editar/borrar notas de cualquier producto.

```ruby
# AÑADIR before_action
before_action :set_nota, only: [:update, :destroy]
before_action :authorize_nota!, only: [:update, :destroy]

private

def set_nota
  @nota = @producto.notas.find(params[:id])
end

def authorize_nota!
  unless current_user.admin? || @nota.user_id == current_user.id
    redirect_to @producto, alert: "No tienes permiso."
  end
end
```

---

### 0.5 CSRF deshabilitado

| Archivo | Línea | Issue |
|---------|-------|-------|
| `registrations_controller.rb` | 3 | `skip_before_action :verify_authenticity_token, only: :create` |
| `sessions_controller.rb` | 3 | `skip_before_action :verify_authenticity_token, only: :create` |

**Acción:** Eliminar ambos `skip_before_action` y asegurar que los forms incluyen CSRF token.

---

### 0.6 Viewport bloquea zoom

**Archivo:** `app/views/layouts/application.html.erb`
**Línea:** 5

```erb
<!-- ANTES -->
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1, user-scalable=no">

<!-- DESPUÉS -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

---

### 0.7 Schema/Model mismatch CRASH

**Modelo:** `User` tiene `has_many :productos, dependent: :nullify`
**Schema:** `productos.user_id` es `null: false`

Cuando se borra un User con productos → `ActiveRecord::NotNullViolation`

**Acción:** Cambiar a `dependent: :destroy` o permitir NULL en `user_id`

---

### 0.8 Eliminar código muerto

| Archivo | Líneas | Qué eliminar |
|---------|--------|--------------|
| `usuarios_controller.rb` | 3 | `skip_before_action :verify_authenticity_token` (vacío) |
| `usuarios_controller.rb` | 217-221 | `find_user_from_cookie` (nunca se usa) |
| `usuarios_controller.rb` | 227-231 | `require_admin` (nunca se usa como before_action) |
| `usuarios_controller.rb` | 233-243 | `terminate_session` + `start_new_session_for` (duplicados del concern Authentication) |
| `productos_controller.rb` | 147-155 | Debug logging |

---

## FASE 1: Extraer JS Inline → Stimulus Controllers

### 1.1 Mapa de extracción

| Vista | JS líneas | Stimulus Controller nuevo |
|-------|-----------|--------------------------|
| `productos/index.html.erb` | 488 | `product_search_controller.js` + `ia_analyze_controller.js` + `mobile_fab_controller.js` |
| `productos/_form.html.erb` | 244 | `ia_modal_controller.js` + `quick_category_controller.js` |
| `productos/show.html.erb` | 187 | `nota_crud_controller.js` + `gallery_controller.js` + `lightbox_controller.js` |
| `layouts/application.html.erb` | 102 | `mobile_drawer_controller.js` + `user_switch_controller.js` + `notifications_controller.js` |
| `productos/new.html.erb` | 82 | `ia_image_recovery_controller.js` |
| `usuarios/new.html.erb` | 52 | Usar `toggle_password_controller.js` existente |
| `configuracion/ia.html.erb` | 34 | `ia_config_controller.js` |
| `usuarios/edit.html.erb` | 15 | Usar `toggle_password_controller.js` existente |
| `sessions/new.html.erb` | 13 | Usar `toggle_password_controller.js` existente |

### 1.2 JS duplicado a eliminar

| Patrón | Archivos | Acción |
|--------|----------|--------|
| `toggleField()` / `togglePassword()` | sessions/new, usuarios/edit, usuarios/new | Usar `toggle_password_controller.js` |
| Etiqueta color/text maps | productos/index (x2), productos/show | Mover a helper Ruby |
| Lógica IA modal | productos/index, productos/_form | 1 solo Stimulus controller |
| HTML modal IA (~125 líneas) | productos/index, productos/_form | Extraer a `_ia_modal.html.erb` partial |

### 1.3 Nuevos archivos a crear

```
app/javascript/controllers/
  product_search_controller.js   (~200 líneas)
  ia_analyze_controller.js       (~150 líneas)
  ia_modal_controller.js         (~200 líneas)
  mobile_fab_controller.js       (~30 líneas)
  mobile_drawer_controller.js    (~50 líneas)
  user_switch_controller.js      (~60 líneas)
  notifications_controller.js    (~40 líneas)
  nota_crud_controller.js        (~60 líneas)
  gallery_controller.js          (~80 líneas)
  lightbox_controller.js         (~60 líneas)
  ia_image_recovery_controller.js (~80 líneas)
  ia_config_controller.js        (~35 líneas)
  quick_category_controller.js   (~50 líneas)
```

### 1.4 Partials a crear

```erb
<%-- Modal de IA compartido entre index y form --%>
app/views/productos/_ia_modal.html.erb

<%-- Badge de etiqueta reutilizable --%>
app/views/productos/_etiqueta_badge.html.erb

<%-- Botón de "volver" reutilizable --%>
app/views/shared/_back_button.html.erb
```

---

## FASE 2: Refactorizar Controladores

### 2.1 ProductosController (400 líneas → ~150)

**Extraer a service objects:**

```
app/services/
  image_search_service.rb    ← buscar_por_imagen + buscar_productos_similares + calcular_similitud
  producto_notifier.rb       ← crear_notificaciones_nuevo_producto
```

**Limpiar:**

| Issue | Líneas | Acción |
|-------|--------|--------|
| Paginación duplicada | 6-38 | Unificar en método privado `filtered_productos` |
| Debug logging | 147-155, 320, 326, 338 | Eliminar |
| Strong params inconsistente | 160 vs 385 | Unificar en un solo `producto_params` |
| SQL interpolation | 15 | Usar parameterized query |
| `generar_nombre_desde_ia` público | 75-109 | Podría ser privado o mover a servicio |

**Estructura propuesta:**

```ruby
class ProductosController < ApplicationController
  before_action :require_no_visitante, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_producto, only: [:show, :edit, :update, :destroy, :fotos_json]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @productos = filtered_productos
  end

  def show
    # ...
  end

  # ... restantes

  private

  def filtered_productos
    base = params[:vistos] ? producto_vistos : Producto.all
    base.includes(:user, :categoria, :fotos_attachments)
        .buscar(params[:q])
        .por_categoria(params[:categoria])
        .por_estado(params[:estado])
        .por_etiqueta(params[:etiqueta])
        .offset((page - 1) * per_page)
        .limit(per_page)
  end

  def producto_params
    params.expect(producto: [:nombre, :descripcion, :precio_compra, :precio_venta, :estado, :categoria_id, :etiqueta, fotos: []])
  end
end
```

---

### 2.2 UsuariosController (244 líneas → ~100)

**Problemas principales:**

| Issue | Líneas | Acción |
|-------|--------|--------|
| Gestión manual de sesiones x5 | 41-50, 54-65, 68-77, 90-99, 115-122 | Usar `current_user` del concern Authentication |
| `terminate_session` duplicado | 233-236 | Eliminar, usar el del concern |
| `start_new_session_for` duplicado | 238-243 | Eliminar, usar el del concern |
| Código muerto | 217-231 | Eliminar `find_user_from_cookie` y `require_admin` |
| Contraseña hardcoded | 165, 199 | Mover a ENV |
| Fallback User.first | 28 | Eliminar |

**Estructura propuesta:**

```ruby
class UsuariosController < ApplicationController
  before_action :require_authentication, except: [:index]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy, :gestionar, :registrados]

  def gestionar
    @usuarios = User.order(:nombre)
    render "index"
  end

  def new
    @usuario = User.new
  end

  def create
    @usuario = User.new(usuario_params)
    @usuario.rol = :admin
    @usuario.email_address = "#{@usuario.nombre.parameterize}@stock.local"
    if @usuario.save
      redirect_to gestionar_usuarios_path, notice: "Usuario creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_admin
    redirect_to(productos_path, alert: "No tienes permiso.") unless current_user&.admin?
  end

  def usuario_params
    params.require(:user).permit(:nombre, :password, :password_confirmation)
  end
end
```

---

### 2.3 CategoriasController

```ruby
before_action :require_no_visitante, only: [:new, :create, :edit, :update, :destroy, :quick_create]
```

### 2.4 NotificacionesController

```ruby
# ANTES (N+1)
current_user.notificaciones.no_leidas.each { |n| n.marcar_como_leida! }

# DESPUÉS
current_user.notificaciones.no_leidas.update_all(leida: true, updated_at: Time.current)
```

### 2.5 NotasController

```ruby
before_action :set_nota, only: [:update, :destroy]
before_action :authorize_nota!, only: [:update, :destroy]

private

def authorize_nota!
  unless current_user.admin? || @nota.user_id == current_user.id
    redirect_to @producto, alert: "No tienes permiso."
  end
end
```

---

## FASE 3: Modelos + Performance DB

### 3.1 Extraer lógica de negocio a services

**Producto (209 líneas)**

| Método | Líneas | Destino |
|--------|--------|---------|
| `generar_embedding` | 40-62 | `app/services/embedding_service.rb` |
| `buscar_por_embedding` + `cosine_similarity` | 110-164 | `app/services/similarity_search_service.rb` |
| `registrar_cambios` | 64-108 | `app/services/audit_log_service.rb` |

**IaUsage (107 líneas)**

| Método | Destino |
|--------|---------|
| `record_request` + `reset_if_needed` | `app/services/rate_limiting_service.rb` |

### 3.2 N+1 Queries

| Ubicación | Fix |
|-----------|-----|
| `ProductoVisto.vistos_recientemente` | Añadir `.includes(:producto)` |
| `NotificacionesController#marcar_todas_leidas` | Usar `update_all` |
| `Producto.buscar_por_embedding` | Considerar cache de embeddings |
| `Producto.registrar_cambios` | Cachear lookups de Categoria |

### 3.3 Validaciones faltantes

```ruby
# User
validates :email_address, presence: true, uniqueness: true
validates :password, length: { minimum: 4 }, on: [:create, :update]

# Producto
validates :codigo, uniqueness: true, allow_nil: true
validates :nombre, length: { maximum: 255 }

# Nota
validates :producto_id, :user_id, presence: true

# Notificacion
validates :producto_id, :user_id, presence: true

# ProductoVisto
validates :producto_id, :user_id, presence: true
```

### 3.4 Schema fixes

| Issue | Acción |
|-------|--------|
| `productos.user_id NOT NULL` vs `dependent: :nullify` | Cambiar a `dependent: :destroy` |
| Tabla `productos_fts` sin uso | Eliminar con migration |
| Sin FK `categorias` → `productos` | Añadir `add_foreign_key` |
| `self.table_name` innecesario en 3 modelos | Eliminar de Nota, Notificacion, ProductoHistorial |
| `IaUsage#record_request` race condition | Usar SQL atómico `UPDATE SET requests_today = requests_today + 1` |

---

## FASE 4: UI/UX + Responsive

### 4.1 Mobile

| Issue | Archivo | Fix |
|-------|---------|-----|
| Sin safe-area-inset | `productos/index.html.erb:34` | Añadir `pb-safe` o `padding-bottom: env(safe-area-inset-bottom)` |
| Tabla no responsive | `usuarios/registrados.html.erb` | Cards en mobile con `md:hidden` / `hidden md:block` |
| Zoom bloqueado | `application.html.erb:5` | Eliminar `user-scalable=no` |
| Botones flotantes usan inline style | `productos/index.html.erb:34` | Mover a Tailwind classes |

### 4.2 Accesibilidad

| Issue | Fix |
|-------|-----|
| 6 modales sin `role="dialog"` | Añadir `role="dialog" aria-modal="true"` |
| Botones hamburger sin aria | Añadir `aria-expanded` + `aria-controls` |
| Imágenes sin alt | Añadir `alt` descriptivo |
| Formularios sin fieldset | Añadir `<fieldset>` + `<legend>` |
| Tablas sin caption | Añadir `<caption>` |
| Inline onclick handlers | Mover a Stimulus controllers |

### 4.3 Consistencia visual

| Issue | Fix |
|-------|-----|
| `passwords/new` y `passwords/edit` usan indigo/gray | Unificar a paleta vintage |
| `onmouseover`/`onmouseout` en 3 vistas | Mover a CSS `:hover` |
| `font-family: 'Playfair Display'` en 12 archivos | Crear clase `.font-display` en CSS |
| Colores hardcoded (#2C1810, #B8860B, etc.) | Usar CSS custom properties existentes |
| Mix `var(--bg-card)` con hex `#F4DCDC` | Unificar a custom properties |

### 4.4 CSS unificado

```css
/* Añadir a application.css */
.font-display {
  font-family: 'Playfair Display', serif;
}

/* Eliminar onmouseover/onmouseout, usar hover */
.btn-accent:hover {
  background-color: #9A7209;
}

/* Safe area para móviles */
.safe-bottom {
  padding-bottom: env(safe-area-inset-bottom, 0px);
}
```

---

## Resumen de Archivos Nuevos

```
app/services/
  image_search_service.rb         # Lógica de búsqueda por imagen
  producto_notifier.rb            # Notificaciones de productos nuevos
  embedding_service.rb            # Generación de embeddings
  similarity_search_service.rb    # Búsqueda por similitud
  audit_log_service.rb            # Registro de cambios
  rate_limiting_service.rb        # Rate limiting IA

app/javascript/controllers/
  product_search_controller.js    # Búsqueda visual en stock
  ia_analyze_controller.js        # Análisis IA de imagen
  ia_modal_controller.js          # Modal de IA
  mobile_fab_controller.js        # Botones flotantes mobile
  mobile_drawer_controller.js     # Menú lateral mobile
  user_switch_controller.js       # Cambio de usuario
  notifications_controller.js     # Panel notificaciones
  nota_crud_controller.js         # CRUD de notas
  gallery_controller.js           # Galería de fotos
  lightbox_controller.js          # Lightbox de imagen
  ia_image_recovery_controller.js # Recuperar imagen IA
  ia_config_controller.js         # Configuración IA
  quick_category_controller.js    # Crear categoría rápida

app/views/productos/
  _ia_modal.html.erb              # Partial del modal IA
  _etiqueta_badge.html.erb        # Partial badge etiqueta

app/views/shared/
  _back_button.html.erb           # Botón volver reutilizable
```

---

## Orden de Ejecución

1. **Fase 0** → Seguridad (2h, impacto alto)
2. **Fase 1** → JS → Stimulus (8h, mantenibilidad)
3. **Fase 2** → Controladores (4h, limpieza)
4. **Fase 3** → Modelos + DB (4h, performance)
5. **Fase 4** → UI/UX (4h, visual)
