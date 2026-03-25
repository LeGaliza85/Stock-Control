# PRD - Product Requirements Document
## StockControl App

---

## 1. Visión del Producto

**Nombre:** StockControl
**Descripción:** Aplicación web para gestión de stock de antigüedades y objetos variados, con captura de fotos y acceso compartido entre miembros del equipo.
**Plataforma:** Web (responsive, SSR)
**Usuarios objetivo:** Equipo pequeño (2-5 personas)

---

## 2. Problema que Resuelve

Controlar el inventario de antigüedades y objetos variados de forma rápida, con fotos y acceso compartido entre varios miembros del equipo desde cualquier navegador.

---

## 3. Stack Tecnológico

| Componente | Tecnología |
|-----------|------------|
| Framework web | Ruby on Rails 8 (Hotwire/Turbo) |
| Base de datos | SQLite3 |
| Almacenamiento fotos | Active Storage (disco local) |
| Autenticación | Rails Authentication (built-in) |
| Búsqueda por texto | SQLite FTS5 |
| Procesamiento imágenes | libvips |
| Despliegue | Docker Compose |

---

## 4. Usuarios

| Rol | Descripción | Permisos |
|-----|-------------|----------|
| **Admin** | Dueño del inventario | CRUD completo, gestionar equipo, ver todo |
| **Miembro** | Persona del equipo | Crear y editar productos propios, ver todos |

---

## 5. Funcionalidades

### P0 - MVP

| ID | Función | Descripción |
|----|---------|-------------|
| F1 | Captura de foto | Subir foto desde dispositivo o cámara del navegador |
| F2 | Crear producto | Formulario con: nombre, descripción, precio compra, precio venta, estado, año aprox., uso, categoría |
| F3 | Lista de stock | Grid/lista con fotos, nombre, precios y estado |
| F4 | Editar/eliminar producto | Modificar cualquier campo del producto |
| F5 | Login/Registro | Autenticación por email y contraseña |
| F6 | Búsqueda por texto | Buscar productos por nombre, descripción o filtros (SQLite FTS5) |

### P1 - Importante

| ID | Función | Descripción |
|----|---------|-------------|
| F7 | Filtros avanzados | Por categoría, estado, rango de precios, fecha |
| F8 | Múltiples fotos | Varios ángulos del mismo producto |
| F9 | Gestión de equipo | Admin invita/elimina miembros |

### P2 - Deseable

| ID | Función | Descripción |
|----|---------|-------------|
| F10 | Modo oscuro | Tema oscuro para la aplicación |
| F11 | Notificaciones | Alertas de stock bajo o cambios |

---

## 6. Modelo de Datos

### Producto

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| id | integer (PK) | Sí | Identificador único |
| nombre | string | Sí | Nombre del producto |
| descripcion | text | Sí | Descripción breve |
| precio_compra | decimal | Sí | Precio al que se compró |
| precio_venta | decimal | Sí | Precio al que se venderá |
| estado | enum | Sí | nuevo, bueno, aceptable, desgastado, reparacion |
| año_aprox | integer | No | Año aproximado de creación |
| uso | string | No | Para qué se usa el objeto |
| categoria | string | Sí | Categoría del producto |
| user_id | FK Usuario | Sí | Quién creó el producto |
| created_at | datetime | Sí | Fecha de creación |
| updated_at | datetime | Sí | Última actualización |

*Fotos gestionadas por Active Storage (has_many_attached :fotos)*

### Usuario

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| id | integer (PK) | Sí | Identificador único |
| email_address | string | Sí | Email del usuario |
| nombre | string | Sí | Nombre visible |
| rol | enum | Sí | admin, miembro |
| password_digest | string | Sí | Contraseña (bcrypt) |
| created_at | datetime | Sí | Fecha de creación |

---

## 7. Páginas

| Página | Descripción | Ruta |
|--------|-------------|------|
| Login | Autenticación por email/contraseña | `/session/new` |
| Registro | Crear cuenta nueva | `/registration/new` |
| Stock List | Grid con productos, precios, fotos | `/productos` |
| Detalle Producto | Toda la info + fotos | `/productos/:id` |
| Crear Producto | Formulario completo | `/productos/new` |
| Editar Producto | Formulario pre-rellenado | `/productos/:id/edit` |
| Ajustes | Perfil, gestión equipo, logout | `/settings` |

---

## 8. Criterios de Aceptación

- [ ] Crear producto con foto toma menos de 30 segundos
- [ ] La búsqueda devuelve resultados en menos de 1 segundo
- [ ] La app es usable desde móvil (responsive)
- [ ] Las fotos se almacenan y sirven correctamente con Active Storage
- [ ] Docker Compose levanta todo el entorno con un solo comando

---

## 9. Métricas de Éxito

| Métrica | Objetivo |
|---------|----------|
| Tiempo crear producto con foto | < 30 segundos |
| Tiempo búsqueda | < 1 segundo |
| Uptime | > 99% |
