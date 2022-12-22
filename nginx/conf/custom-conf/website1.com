upstream minio-server {
        server minio:9000;
}

server {
        listen 80;
        listen [::]:80;
        server_name website1.com www.website1.com;

        location / {
                proxy_pass http://minio-server/personal-website/out$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
            root /var/www/certbot/personal-website/;
        }
}
