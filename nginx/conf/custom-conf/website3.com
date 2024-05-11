server {
        listen 80;
        listen [::]:80;

        root /var/www/website3.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name website3.com www.website3.com;

        resolver 8.8.8.8;

        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Client-IP $remote_addr;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_pass http://timebite.net/$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
            alias /var/www/certbot/.well-known/acme-challenge/;
        }
}
