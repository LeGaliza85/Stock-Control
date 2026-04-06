# Design: UI/UX Improvements

## Architecture

We will implement the UI improvements mostly on the frontend using Rails views, CSS, and Turbo/Hotwire, keeping Javascript to a minimum.

## Components

### 1. Flash Messages (Toasts)
- Extract a `_flash.html.erb` partial.
- Render it in `application.html.erb`.
- Add CSS classes `.toast`, `.toast-success`, `.toast-error`.
- Add a tiny Stimulus controller `toast_controller.js` to auto-dismiss toasts after 3-5 seconds.

### 2. Turbo Progress Bar
- Enable and style the default Turbo progress bar in `application.css`.
- `.turbo-progress-bar { height: 3px; background-color: var(--accent); }`

### 3. Empty States
- Create `app/views/shared/_empty_state.html.erb`.
- Accepts locals: `title`, `description`, `icon`, `action_url`, `action_text`.

### 4. Breadcrumbs
- Create a `breadcrumbs_helper.rb` or simply a `_breadcrumbs.html.erb` partial.
- Render in `application.html.erb` before the main content yield.

### 5. Form Polishing
- Update `app/assets/stylesheets/application.css` with `.form-group`, `.input-field`, `.btn-primary` standard classes.
- Update `app/views/productos/_form.html.erb` to use these classes.

## Data Model
- No changes to the database.

## API / Interfaces
- No changes to APIs.