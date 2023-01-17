server {
        listen 80;
        listen [::]:80;
        server_name tracking.website1dev.com www.tracking.website1dev.com;

        return 301 https://$host$request_uri;
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name tracking.website1dev.com www.tracking.website1dev.com;
        
        # self-signed certificates
        ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

        location / {
                proxy_pass http://umami-server$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
                alias /var/www/certbot/.well-known/acme-challenge/;
        }
}
