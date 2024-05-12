server {
        listen 80;
        listen [::]:80;
        server_name tracking.busacchi.com www.tracking.busacchi.com;

        return 301 https://$host$request_uri;
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name tracking.busacchi.com www.tracking.busacchi.com;
        
        # self-signed certificates
        # ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
        # ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

        # letsencrypt certificates
        ssl_certificate     /etc/letsencrypt/live/certificates.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/certificates.com/privkey.pem;

        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Client-IP $remote_addr;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_pass http://umami-server$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
                alias /var/www/certbot/.well-known/acme-challenge/;
        }
}
