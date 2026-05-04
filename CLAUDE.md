# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start development server (Puma + Tailwind CSS watcher)
bin/dev

# Database setup
bundle exec rake db:create db:migrate db:seed

# Run all tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/models/locacao_spec.rb

# Run a single example by line number
bundle exec rspec spec/models/locacao_spec.rb:42

# Lint
bundle exec rubocop

# Security scan
bundle exec brakeman
```

The dev server composes `puma` and `tailwindcss:watch` via `Procfile.dev`.

## Architecture

**Rails 8.1 fleet/rental management app** — all domain terms are in Portuguese.

### Authentication & Authorization

- Session-based auth using `bcrypt` (`has_secure_password`). Session stored in `session[:usuario_id]`.
- Google OAuth via OmniAuth (`omniauth-google-oauth2`). Callback at `GET /auth/google_oauth2/callback → sessions#oauth_callback`. OAuth users skip password requirements — `Usuario#password_required?` gates this.
- `Current.usuario` (via `ActiveSupport::CurrentAttributes`) is set by `ApplicationController#set_current_usuario` on every request and reset after.
- No authorization gem — access control is enforced by `require_login` in `ApplicationController`. The app gracefully degrades when the DB is unreachable (`database_connected?` check).
- Three `perfil` roles: `admin`, `operador`, `socio`.

### Audit Trail (`tracked_by_users`)

Almost every model has `created_by` and `updated_by` UUID foreign keys pointing to `usuarios`. This is wired through a concern called `tracked_by_users` (defined somewhere in models or a concern — check `ApplicationRecord` if not in `app/models/concerns/`). Controllers set these manually: `@record.created_by = Current.usuario`.

### Domain Models

- **Veiculo** — fleet vehicle. Status enum: `disponivel / locado / manutencao / inativo`. Tracks financial data (`valor_compra`, `valor_semanal`, etc.) and exposes `taxa_retorno` / `retorno_total` computed from `Evento` sums.
- **Cliente** — renter. Has CNH (driver's license) validity tracking.
- **Locacao** — rental contract linking `Cliente` ↔ `Veiculo`. Status: `ativa / encerrada / inadimplente / cancelada`. On transition to `encerrada`, a callback sets `data_fim` and flips the vehicle back to `disponivel`.
- **Evento** — the primary financial/operational ledger entry. Covers: `pagamento_semanal`, `manutencao`, `gasto_empresa`, `retirada`, `devolucao`, `aquisicao_veiculo`, `saida_frota`. Has `fluxo` (entrada/saida) and `status` (pendente/pago/parcial). All monetary flows go through `Evento`.
- **Anexo** — file metadata record. `arquivo_url` must be a Google Drive URL (validated). Belongs to `Veiculo` (required) and optionally to `Evento`.
- **Socio / ParticipacaoSocio** — partner ownership stake in vehicles (many-to-many via `participacao_socios`).
- **AuditoriaLog** — append-only audit log written by service objects, not ActiveRecord callbacks.

### Service Objects

All inherit from `ApplicationService`, which provides `self.call(...)` → `new(...).call`.

Under `app/services/`:
- `Locacoes::RegistrarPagamentoSemanal` — creates an `Evento`, updates `Locacao` status, writes an `AuditoriaLog`, all in one transaction.
- `Locacoes::IniciarLocacao` — triggered from `EventosController` when a `retirada` event is saved.
- `Locacoes::EncerrarLocacao` — triggered when a `devolucao` event is saved.
- `Veiculos::RegistrarManutencao` — maintenance registration.
- `Veiculos::MaintenanceTracker` — maintenance tracking helper.
- `GoogleDriveService` — wraps the `google_drive` gem. Supports OAuth refresh token (preferred) or service account JSON. Uploads files publicly readable, returns `file_url` and `view_url`.
- `EventoUploadProcessor` — validates and pre-processes file uploads (PDF/JPEG/PNG/Word, 5 MB max), generating structured filenames via `EventoFilenameGenerator` before handing off to Google Drive.

### Controller Concerns

- `LoadAssociations` — provides `load_clientes`, `load_veiculos`, `load_locacoes` helpers used in forms.
- `EnumParamsConverter` — converts enum form params to integers before `update`/`create` (`convert_enum_params(permitted, :status, :tipo_evento, ...)`).

### File Uploads

Files are stored on **Google Drive**, not ActiveStorage. `Anexo` records store the Drive URL. `GoogleDriveService` is initialized per-request with credentials from env vars. The `EventosController#upload` action (POST `/eventos/upload`) is a collection endpoint for batch pre-processing; individual uploads happen inside `upload_anexos_for_evento`.

### Database

PostgreSQL with UUID primary keys (`pgcrypto` extension, `id: :uuid`). SQLite is used for the test environment (see `Gemfile` — `sqlite3` in `:development, :test`). Pagination via `kaminari` (25 per page). Rate limiting via `rack-attack`.

### Frontend

Hotwire (Turbo + Stimulus) with importmap. Tailwind CSS via `tailwindcss-rails`. Most controller actions respond to both `format.html` and `format.turbo_stream`. No Node.js/npm pipeline.

### Environment Variables

Key env vars (see `.env.example` if present):
- `DATABASE_URL` — PostgreSQL connection
- `RAILS_MASTER_KEY`
- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` — Google OAuth for user login
- `GOOGLE_DRIVE_CLIENT_ID`, `GOOGLE_DRIVE_CLIENT_SECRET`, `GOOGLE_DRIVE_REFRESH_TOKEN` — Google Drive file storage (preferred)
- `GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY` — fallback service account JSON
- `GOOGLE_DRIVE_DEFAULT_FOLDER_ID`, `GOOGLE_DRIVE_VEICULOS_FOLDER_ID`
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_BUCKET`

### Testing

RSpec with FactoryBot and Shoulda Matchers. Test database is SQLite. OmniAuth is set to `test_mode = true` in `spec/rails_helper.rb`. Support files in `spec/support/` are auto-required. Run a specific spec type with `bundle exec rspec spec/models/` or `spec/requests/`.
