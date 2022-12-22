upstream minio-server {
        server minio:9000;
}

server {
        listen 80;
        listen [::]:80;
        server_name website1.com www.website1.com;

        return 301 https://$host$request_uri;
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name website1.com www.website1.com;
        ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

        location / {
                proxy_pass http://minio-server/personal-website/out$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
            root /var/www/certbot/personal-website/;
        }
}
