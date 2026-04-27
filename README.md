# MotriX

MotriX is a Rails 8 fleet and rental management app built with PostgreSQL, Hotwire, Tailwind, Supabase-ready configuration, GitHub workflows, and Render deploy support.

## Stack

- Ruby on Rails 8.0
- PostgreSQL with UUID primary keys
- Hotwire with importmap
- Tailwind CSS
- Supabase for hosted PostgreSQL and file URL storage
- Render for hosting

## Domain

The app includes models, migrations, and starter UI for:

- `usuarios`
- `clientes`
- `veiculos`
- `locacoes`
- `eventos`
- `socios`
- `participacao_socios`
- `anexos`
- `auditoria_logs`

Weekly payments and maintenance are handled by service objects:

- `Locacoes::RegistrarPagamentoSemanal`
- `Veiculos::RegistrarManutencao`

## Local setup

1. Install PostgreSQL locally or prepare a Supabase database.
2. Copy `.env.example` into your preferred env manager and fill the values.
3. Run:

```bash
bundle install
bundle exec rake db:create db:migrate db:seed
bin/dev
```

If you are using Supabase locally or in production, prefer `DATABASE_URL`.

## Deploy

### Supabase

- Create a PostgreSQL project in Supabase.
- Copy the connection string into `DATABASE_URL`.
- Keep `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` available for future file and API integrations.

### Render

- Connect the repo from GitHub.
- Use the included `render.yaml`.
- Add `DATABASE_URL`, `RAILS_MASTER_KEY`, and the `SUPABASE_*` variables in Render.

## Notes

- The dashboard is mobile-first and degrades gracefully when the database is not configured yet.
- The generated Rails defaults were trimmed to keep the codebase simple and maintainable.
