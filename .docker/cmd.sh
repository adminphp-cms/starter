#!/bin/sh
set -e

# Without APP_KEY, the app container makes one and keeps it in the storage
# volume, which the queue and scheduler containers share: the site works with a
# plain `docker compose up`. Set APP_KEY yourself for a real deployment.
if [ -z "$APP_KEY" ]; then
    key_file=/app/storage/app/.app_key

    if [ ! -s "$key_file" ]; then
        echo " [-] Generating an application key"
        php -r 'echo "base64:".base64_encode(random_bytes(32));' > "$key_file"
    fi

    APP_KEY=$(cat "$key_file")
    export APP_KEY
fi

echo " [-] Caching Laravel config, routes and views"
php artisan config:cache
php artisan route:cache
php artisan view:cache

role=${CONTAINER_ROLE:-app}

case "$role" in
    app)
        echo " [-] Migrating the database"
        php artisan migrate --force

        # The demo content goes in once, on a database without any admin user.
        if [ "$ADMINPHP_DEMO" = "true" ] && ! php -r '
            require "vendor/autoload.php";
            $app = require "bootstrap/app.php";
            $app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
            exit(AdminPhp\Models\User::query()->exists() ? 0 : 1);
        '; then
            echo " [-] Filling the site with the demo content"
            php artisan db:seed --force
            echo " [-] Demo ready: sign in at /admin with admin@example.com / password"
        fi

        # The symlink is gitignored, so it is absent from the image: without
        # this, everything on the `public` media disk answers 404.
        echo " [-] Linking storage/app/public into the document root"
        php artisan storage:link --force

        echo " [-] Container running as app"
        exec frankenphp run --config /etc/caddy/Caddyfile
        ;;
    queue)
        echo " [-] Container running as queue worker"
        exec php artisan queue:work --tries=3
        ;;
    scheduler)
        echo " [-] Container running as scheduler"
        exec php artisan schedule:work
        ;;
    *)
        echo " [X] Could not match the container role \"$role\""
        exit 1
        ;;
esac
