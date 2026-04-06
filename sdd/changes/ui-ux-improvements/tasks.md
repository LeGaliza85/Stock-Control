# Tasks: UI/UX Improvements

## Phase 1: Setup & Global Components

- [ ] 1. Create `app/views/shared/_flash.html.erb` and render it in `app/views/layouts/application.html.erb`.
- [ ] 2. Add CSS styles for flash messages (toasts) in `app/assets/stylesheets/application.css`.
- [ ] 3. Create Stimulus controller `app/javascript/controllers/toast_controller.js` for auto-dismiss functionality.
- [ ] 4. Style the Turbo progress bar in `app/assets/stylesheets/application.css` and ensure it's active.

## Phase 2: Navigation & Empty States

- [ ] 5. Create `app/views/shared/_empty_state.html.erb` with standard "Vintage Catalog" styling.
- [ ] 6. Update `app/views/productos/index.html.erb` to use the new `_empty_state` partial when there are no products.
- [ ] 7. Create `app/views/shared/_breadcrumbs.html.erb` and integrate into `app/views/layouts/application.html.erb`.
- [ ] 8. Update controllers to pass breadcrumb data, or use a helper to define breadcrumbs.

## Phase 3: Form Polishing

- [ ] 9. Add standard form CSS classes (`.input-field`, `.btn-primary`, `.form-group`) in `app/assets/stylesheets/application.css`.
- [ ] 10. Update `app/views/productos/_form.html.erb` to use the new CSS classes.
- [ ] 11. Ensure form validation errors are displayed clearly and beautifully.