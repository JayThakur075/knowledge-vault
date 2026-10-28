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
- Responsive layout, Rails 8, SQLite, Propshaft, Solid Queue, and Solid Cache

## Stack

- Ruby 3.4.4 (`.ruby-version`)
- Rails 8.1.4
- Active Record with SQLite
- Rails built-in authentication and bcrypt
- RSpec Rails 8
- Propshaft and Hotwire
- Solid Queue for production jobs; Solid Cache for production caching

## Prerequisites

Install Ruby 3.4.4, SQLite 3, and Bundler 4.0.1. `bin/setup` installs the bundle and prepares the database.

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

Development and test use local SQLite databases under `storage/`. Database preparation is safe for existing data:

```sh
bin/rails db:prepare
```

The tag ownership migration preserves note assignments and splits a formerly shared tag into per-user copies when needed. Production currently uses separate SQLite databases for the main app, cache, queue, and cable. Persistent storage is required. For multi-server or high-write production use, configure PostgreSQL and an appropriate shared deployment topology.

## Tests and code style

```sh
bundle exec rspec
bin/rubocop --cache false
git diff --check
```

## Background jobs

Production uses Solid Queue and the included recurring schedule enqueues a weekly review every Monday at 9am. The job processes users in batches and writes only each user's stale-note count to that user's cache key.

In development, `bin/dev` starts Puma with the Solid Queue supervisor, so local jobs use SQLite and run without a separate process. To run a worker separately instead, unset `SOLID_QUEUE_IN_PUMA` and use:

```sh
bin/jobs
```

The Kamal template is configured to run the Solid Queue supervisor in Puma for a single server. For separate worker hosts, disable `SOLID_QUEUE_IN_PUMA` and run `bin/jobs` on a worker with access to the same queue database. Development uses Solid Queue and `bin/dev` starts its supervisor in Puma.

## Caching

Development and production use Solid Cache in separate SQLite databases. Dashboard statistics use a cache key scoped to the signed-in user's ID and data version, with a five-minute expiry. Tests use a null cache store. Run `bin/rails db:prepare` after updating the application to prepare configured databases.

## Docker

The repository includes a production Dockerfile and Kamal configuration. Build locally with:

```sh
docker build -t knowledge-vault .
```

Run with a persistent volume and a secret key:

```sh
docker run --rm -p 3000:80 \
  -e RAILS_MASTER_KEY \
  -v knowledge-vault-storage:/rails/storage \
  knowledge-vault
```

Never bake `RAILS_MASTER_KEY` or other credentials into the image. Active Storage uses local disk and currently has no image processing dependency. Back up the persistent volume. Replace SQLite with a managed production database before scaling beyond a suitable single-node deployment.

## Deployment preparation

Kamal is included, but no public deployment has been performed. Before deployment, set a real server address, image registry, domain, credentials, and persistent-volume backup strategy in `config/deploy.yml` and `.kamal/secrets`. Configure TLS and production database access. Keep secrets in environment or the platform's secret manager, not in Git.

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
- Add a supported PostgreSQL deployment profile and automated backup procedure
- Add user-configurable review scheduling
