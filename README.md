# Today We Ate

Today We Ate is a small Rails 8 application that lets people log every meal, rate it, and see quick insights about their eating habits. Users can sign up with email + password (name required) or continue with Google. Separate login and signup pages are available.

## Local setup

1. Install Ruby 4.0.0 (the repo uses `rbenv` via `.ruby-version`).
2. Install and start PostgreSQL (the app defaults to the local URLs `postgresql://localhost/today_we_ate_development` and `postgresql://localhost/today_we_ate_test`; override with `DEV_DATABASE_URL` / `TEST_DATABASE_URL` if needed).
3. Install dependencies and build the databases:
   ```bash
   bundle install
   bin/rails db:prepare
   ```
4. (Optional) seed demo data for the developer strategy:
   ```bash
   bin/rails db:seed
   ```
5. Start the application:
   ```bash
   bin/dev
   ```

The default login buttons expect OAuth credentials to be present. When running locally you can click "Developer sign in" on the landing page to skip third-party providers.

## OAuth configuration

Add the following environment variables (e.g., via `bin/dev` or a `.env` file sourced before the server starts):

| Provider | Required variables |
| --- | --- |
| Google | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` |
<!-- Facebook sign-in removed -->
<!-- Apple sign-in removed -->

The middleware automatically skips any provider whose variables are missing so you can roll them out incrementally.

## Database configuration

- Development uses `DEV_DATABASE_URL` (fallback `postgresql://localhost/today_we_ate_development`).
- Test uses `TEST_DATABASE_URL` (fallback `postgresql://localhost/today_we_ate_test`).
- Production requires `DATABASE_URL`; optional `CACHE_DATABASE_URL`, `QUEUE_DATABASE_URL`, and `CABLE_DATABASE_URL` override the additional role databases otherwise they reuse `DATABASE_URL`.

After adjusting any of these variables, run `bin/rails db:prepare` to ensure the new database exists and is migrated.

## Deployment

The repository includes a production-ready `docker-compose.yml` plus a GitHub Actions workflow that targets a self-hosted runner.

### Manual deploy with Docker Compose

1. Copy `.env.production.example` to `.env.production` and edit the values (at minimum set `RAILS_MASTER_KEY`, database credentials, and `DATABASE_URL`).
2. Build and start the stack:
   ```bash
   docker compose build --pull web
   docker compose up -d db
   docker compose run --rm web ./bin/rails db:migrate
   docker compose up -d --remove-orphans web
   ```

### Push-to-main automation

1. Install the GitHub Actions runner on your deployment host and register it with the labels `self-hosted`, `linux`, and `home` (or update `.github/workflows/deploy.yml` to match your labels).
2. Ensure Docker + the Compose plugin are available to the runner user.
3. Add the following repository **secrets** (Settings → Secrets and variables → Actions):
   - `RAILS_MASTER_KEY`
   - `PRODUCTION_DATABASE_URL` (e.g., `postgresql://postgres:postgres@db:5432/today_we_ate_production` or point to an external database)
   - Optional overrides: `POSTGRES_USER`, `POSTGRES_PASSWORD`
4. (Optional) Add repository **variables** for non-sensitive values such as `WEB_PORT`, `WEB_CONCURRENCY`, and `POSTGRES_DB`.

On every push to `main` (or via the "Run workflow" button) the `deploy` workflow will:

- Check out the new commit on the runner.
- Write `.env.production` from your secrets/variables.
- Build the container image and ensure the PostgreSQL service is running.
- Run `docker compose run --rm web ./bin/rails db:migrate`.
- Restart the `web` service via `docker compose up -d --remove-orphans web`.

Monitor the job logs in GitHub Actions to verify each step. The containers live on the runner host, so `docker compose ps` there shows the currently deployed version.

## Features

- Email/password accounts with separate login and signup pages, plus Google OAuth and a developer fallback in non-production environments.
- `Meal` model for logging what was eaten, where it came from (home, takeout, restaurant), rating, notes, and when you'd like to try it again.
- Dashboard with:
  - quick logging form
  - "most eaten" lists for the week, month, and year
  - alerts for meals you have not eaten recently
  - sourcing distribution (home vs. takeout vs. restaurant)
  - recent meals list
- Meal history table for a longer look-back period.

## Testing

Run the test suite with:

```bash
bin/rails test
```

Model, service, and analytics tests cover the core domain logic.
