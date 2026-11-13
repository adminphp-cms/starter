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

PHP 8.3 or later with the `gd` and `exif` extensions, Composer, Node.js 20 or later.

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
