server {
        listen 80;
        listen [::]:80;

        root /var/www/website2.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name website2.com www.website2.com;

        resolver 8.8.8.8;

        location / {
                proxy_pass http://timebite.net/$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
            root /var/www/certbot/timebite-website/;
        }
}
