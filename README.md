# AdminPHP Starter

A Laravel site ready to edit with [AdminPHP](https://github.com/adminphp-cms/core): start a new
site from it, or run it to see what AdminPHP does.

It comes with:

- **Articles**: title, lead, cover and a content made of blocks, with drafts, scheduling and revisions.
- **Pages**: a tree of pages made of blocks, one of them chosen as the homepage.
- **Menu**: the main menu on two levels, linking to pages, articles or any address.
- **Blocks**: text, image and quote, each rendered by its own Blade view.
- **Settings**: site name, tagline, homepage, logo and contact e-mail.
- **The public site**: homepage, article list and pages, with Tailwind CSS.

## Requirements

PHP 8.3 or later with the `gd` and `exif` extensions, Composer, Node.js 20 or later; or only Docker.

## Start a site

```bash
composer create-project adminphp-cms/starter my-site --repository='{"type":"vcs","url":"https://github.com/adminphp-cms/starter"}' --stability=dev
cd my-site
npm install && npm run build
php artisan adminphp:user
```

Or from a clone:

```bash
git clone https://github.com/adminphp-cms/starter.git my-site
cd my-site
composer run setup
php artisan adminphp:user
```

The site uses SQLite by default. Open `/` for the site and `/admin` for the admin.

## Run it with Docker

No PHP, Composer or Node on your computer? Docker runs the starter with MariaDB and Redis:

```bash
git clone https://github.com/adminphp-cms/starter.git my-site
cd my-site
docker compose up --build
```

Open http://localhost:8000. The first start fills the site with the demo content: sign in at `/admin` with
`admin@example.com`, password `password`. Five containers run:

| Service | Role |
| --- | --- |
| `app` | the site and the admin, served by FrankenPHP; it migrates the database on every start |
| `queue` | the queue worker, which makes the smaller copies of the uploaded images |
| `scheduler` | Laravel's scheduler |
| `mariadb` | the database |
| `redis` | cache, sessions and queue |

- `ADMINPHP_DEMO=false docker compose up` starts from an empty site: create your first user with
  `docker compose exec app php artisan adminphp:user`.
- `APP_PORT=8080 docker compose up` serves the site on another port.
- The database, Redis and the uploaded files live in Docker volumes: `docker compose down` keeps them,
  `docker compose down -v` erases them.
- The code is built into the image: run `docker compose up --build` after changing it.

Without `APP_KEY`, the `app` container generates one and keeps it in the storage volume. For a real
deployment, set `APP_KEY` and the passwords of `compose.yaml` yourself.

## See the demo

Fill the site with demo content: articles in every state, a page tree, a menu, images and users.

```bash
composer run demo
```

It **erases the database**, then signs you in at `/admin` with `admin@example.com` or
`editor@example.com`, password `password`. Never run it on a site in production.

## Make it yours

- Modules live in `app/AdminPhp/Modules`, blocks in `app/AdminPhp/Blocks`, settings in
  `app/AdminPhp/Settings`; they are registered in `AppServiceProvider`.
- Generate more with `php artisan adminphp:make:module` and `php artisan adminphp:make:block`.
- The site's views are in `resources/views`: one view per block in `resources/views/blocks`.

## Tests

```bash
composer test
```
