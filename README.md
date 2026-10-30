# Knowledge Vault

Knowledge Vault is a personal library for developers to save, organize, search, and revisit technical knowledge. It is built as a server-rendered Rails application with per-user data ownership.

## Features

- User registration, sign in, sign out, password reset, and protected private pages
- Notes with content, type, favorite status, category, and multiple tags
- Combined title, content, and tag search; category, type, favorite, and tag filters
- Ten notes per page, with active filters retained when paging
- User-owned categories and tags
- Saved development links with categories, tags, search, and URL validation
- Dashboard statistics and recently updated notes
- Weekly background review that counts notes not updated in 30 days, without logging note contents
- Per-user dashboard statistic caching
- Responsive layout, Rails 8, PostgreSQL, Propshaft, Solid Queue, Solid Cache, and Solid Cable

## Stack

- Ruby 3.4.4 (`.ruby-version`)
- Rails 8.1.4
- Active Record with PostgreSQL
- Rails built-in authentication and bcrypt
- RSpec Rails 8
- Propshaft and Hotwire
- Solid Queue for production jobs; Solid Cache for production caching

## Prerequisites

Install Ruby 3.4.4, PostgreSQL 12 or newer, and Bundler 4.0.1. Create a local PostgreSQL role matching your operating-system username (or set `PGUSER` and `PGPASSWORD`). `bin/setup` installs the bundle and prepares the databases.

## Run locally

```sh
bin/setup
bin/dev
```

Open <http://localhost:3000>. You can register at `/sign_up` or use the development demo account:

- Email: `demo@knowledgevault.local`
- Password: `VaultDemo123!`

To clear the development app data and reload the demo records, run `RAILS_ENV=development bin/rails db:seed:replant`. This removes existing development records before loading the demo data. Seeds are disabled in production. `bin/rails server` also starts the web process without the development process manager.

## Database

All environments use PostgreSQL. Development uses separate databases for the app, Solid Cache, and Solid Queue. Production also uses a separate Solid Cable database. Rails creates the configured local databases when you run:

```sh
bin/rails db:prepare
```

The existing ignored SQLite files under `storage/` are left untouched, but the app no longer reads them. PostgreSQL databases start with the current schema; run `bin/rails db:seed` to load the demo account and sample content. The tag ownership migration preserves note assignments and splits a formerly shared tag into per-user copies when needed.

For production, configure four PostgreSQL connection URLs. `DATABASE_URL` is the main app database; `CACHE_DATABASE_URL`, `QUEUE_DATABASE_URL`, and `CABLE_DATABASE_URL` point to separate databases on the same PostgreSQL server. Do not point these variables at the same database. Keep these URLs in the host's secret/environment settings, not in Git.

## Tests and code style

```sh
bundle exec rspec
bin/rubocop --cache false
git diff --check
```

## Background jobs

Production uses Solid Queue and the included recurring schedule enqueues a weekly review every Monday at 9am. The job processes users in batches and writes only each user's stale-note count to that user's cache key.

In development, `bin/dev` starts Puma with the Solid Queue supervisor, so local jobs use the configured PostgreSQL queue database. To run a worker separately instead, unset `SOLID_QUEUE_IN_PUMA` and use:

```sh
bin/jobs
```

The Kamal template is configured to run the Solid Queue supervisor in Puma for a single server. For separate worker hosts, disable `SOLID_QUEUE_IN_PUMA` and run `bin/jobs` on a worker with access to the same queue database. Development uses Solid Queue and `bin/dev` starts its supervisor in Puma.

## Caching

Development and production use Solid Cache in separate PostgreSQL databases. Dashboard statistics use a cache key scoped to the signed-in user's ID and data version, with a five-minute expiry. Tests use a null cache store. Run `bin/rails db:prepare` after updating the application to prepare configured databases.

## Docker

The repository includes a production Dockerfile and Kamal configuration. Build locally with:

```sh
docker build -t knowledge-vault .
```

Run with the four database URLs and a secret key set in your environment:

```sh
docker run --rm -p 3000:80 \
  -e RAILS_MASTER_KEY \
  -e DATABASE_URL \
  -e CACHE_DATABASE_URL \
  -e QUEUE_DATABASE_URL \
  -e CABLE_DATABASE_URL \
  knowledge-vault
```

Never bake database URLs, `RAILS_MASTER_KEY`, or other credentials into the image. Active Storage uses local disk and currently has no image processing dependency; configure persistent file storage if uploads are added.

## Deployment preparation

Kamal is included, but no public deployment has been performed. Before deployment, set a real server address, image registry, domain, database URLs, and credentials in `config/deploy.yml` and `.kamal/secrets`. Configure TLS and PostgreSQL backups. Keep secrets in environment or the platform's secret manager, not in Git.

## Architecture

`User` owns `Note`, `Category`, `Tag`, `Link`, and authentication `Session` records. Notes optionally belong to a category and connect to tags through `NoteTag`; links optionally belong to a category and connect to tags through `LinkTag`. Tags are unique per user. Controllers scope every private record lookup through `Current.user`, while join models also validate tag ownership. Deleting a category leaves its notes and links in place without a category.

## Project structure

- `app/models`: ownership, validations, and associations
- `app/controllers`: authentication, notes, categories, dashboard, and saved links
- `app/jobs`: background review work
- `app/views`: server-rendered pages and forms
- `db/migrate`: incremental schema changes
- `spec`: model and request behavior tests
- `config`: routes, database, Solid Queue, and Solid Cache setup

## Security notes

All notes, categories, links, tags, and dashboard data are scoped to the signed-in user. Passwords are stored as bcrypt digests, sign-in is rate limited, and session cookies are signed and HTTP-only. Note and link parameters do not permit owner IDs. External resource links open with `noopener noreferrer`. Keep Rails credentials and production master keys out of source control.

## Future improvements

- Add browser-level tests for responsive layouts and full workflows
- Add tag and link pagination if saved-resource volumes require it
- Add an automated PostgreSQL backup procedure
- Add user-configurable review scheduling
