# Today We Ate

Today We Ate is a small Rails 8 application that lets people log every meal, rate it, and see quick insights about their eating habits. Users can sign up with email + password (name required) or continue with Google. Separate login and signup pages are available.

## Local setup

1. Install Ruby 4.0.0 (the repo uses `rbenv` via `.ruby-version`).
2. Install dependencies and build the SQLite databases:
   ```bash
   bundle install
   bin/rails db:prepare
   ```
3. (Optional) seed demo data for the developer strategy:
   ```bash
   bin/rails db:seed
   ```
4. Start the application:
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
