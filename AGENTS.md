# AGENTS.md

## Build & Run Commands

```bash
# Docker-based workflow (recommended)
make build          # Build Docker images
make up             # Start services in background
make down           # Stop services
make server         # Start the Rails app
make console        # Open Rails console
make bundle         # Install gems
make install        # Full setup: build + bundle + db:setup

# Without Docker
bin/setup           # Setup dev environment
bin/rails server    # Start development server
```

## Testing Commands

```bash
# Run all tests
make test                          # Via Docker
bin/rails test                     # Direct

# Run a single test file
bin/rails test test/models/user_test.rb

# Run a specific test by line number or name
bin/rails test test/models/user_test.rb:4
bin/rails test test/controllers/sessions_controller_test.rb -n test_create_with_valid_credentials

# Run all controller/model tests
bin/rails test test/controllers/
bin/rails test test/models/
```

## Lint & Security Commands

```bash
# Ruby style (RuboCop with rubocop-rails-omakase)
bin/rubocop                              # Check all files
bin/rubocop -A                           # Auto-correct safe offenses
bin/rubocop app/models/producto.rb       # Lint single file

# Security analysis
bin/brakeman --quiet --no-pager          # Brakeman security scan
bin/bundler-audit                        # Gem vulnerability audit
bin/importmap audit                      # Importmap vulnerability audit

# Full CI pipeline
bin/ci                                   # Runs setup, lint, security, and tests
```

## Database Commands

```bash
make db.setup      # Drop, create, migrate, seed
make db.migrate    # Run pending migrations
make db.rollback   # Rollback last N migrations (STEP=N)
make db.reset      # Drop + create + migrate + seed
make db.seed       # Run seeds
```

## Code Style Guidelines

### General
- Follow `rubocop-rails-omakase` style (inherited via `.rubocop.yml`)
- Ruby 3.4.5, Rails 8.1.3
- Use 2-space indentation (no tabs)
- Single quotes preferred for strings (Ruby default), double quotes for strings with interpolation
- No trailing whitespace; end files with a newline

### Naming Conventions
- Classes/Modules: `PascalCase` (e.g., `ProductosController`, `SessionTest`)
- Methods/variables: `snake_case` (e.g., `current_user`, `set_producto`)
- Database tables: pluralized snake_case (`productos`, `users`)
- Controllers: pluralized noun + `Controller` suffix
- Test files: `*_test.rb` suffix, mirroring source path
- Fixtures: `test/fixtures/*.yml`, named with singular noun

### Models
- Inherit from `ApplicationRecord`
- Define associations before validations
- Use `validates` for presence, numericality, etc.
- Use `scope` for query chains with lambda syntax: `scope :buscar, ->(term) { ... }`
- Use `enum` with integer values for state fields

### Controllers
- Inherit from `ApplicationController`
- Use `before_action` for shared setup (`set_producto`)
- Private params method named `*_params` using `params.expect`
- Authorization logic in private methods (e.g., `authorize_owner!`)
- Flash messages in Spanish (this app's convention): `"Producto creado exitosamente."`

### Testing
- Framework: Minitest (via `rails/test_help`)
- Parallel execution enabled: `parallelize(workers: :number_of_processors)`
- Fixtures for test data (`fixtures :all`)
- Custom helpers in `test/test_helpers/`, auto-included via `ActiveSupport.on_load`
- Use `setup` blocks for shared test state
- Integration tests: `ActionDispatch::IntegrationTest`
- Model tests: `ActiveSupport::TestCase`

### Imports & Dependencies
- Gems listed in `Gemfile`; do not add gems without checking existing usage
- Use `require: false` for gems not needed at boot (e.g., `kamal`, `thruster`)
- Shared concerns go in `app/controllers/concerns/` or `app/models/concerns/`

### Error Handling
- Validation errors rendered via `render :new, status: :unprocessable_entity`
- Authorization failures: `redirect_to` with flash `:alert`
- Use `find` (raises `ActiveRecord::RecordNotFound`) over `find_by` for required records

## Docker Workflow
- `Dockerfile` for production, `Dockerfile.dev` for development
- `docker-compose.yml` defines `app` and `worker` services
- Run commands via `docker compose run --rm app <command>`

## Project Structure Notes
- App name: `StockControl` (Spanish domain: `Producto`, `estado`, `categoria`)
- Auth: custom session-based auth using `bcrypt`, `has_secure_password`
- Assets: Tailwind CSS via `tailwindcss-rails`, JS via importmaps
- Database: SQLite3 with FTS5 full-text search in `Producto.buscar` scope
- No existing Cursor rules (`.cursorrules` or `.cursor/rules/`) or Copilot instructions (`.github/copilot-instructions.md`)
