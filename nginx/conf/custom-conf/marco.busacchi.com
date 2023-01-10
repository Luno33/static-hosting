server {
        listen 80;
        listen [::]:80;
        server_name marco.busacchi.com www.marco.busacchi.com;

        return 301 https://$host$request_uri;
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name marco.busacchi.com www.marco.busacchi.com;
        
        # self-signed certificates
	ssl_certificate     /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

        # letsencrypt certificates
	# ssl_certificate     /etc/letsencrypt/live/certificates.com/fullchain.pem;
        # ssl_certificate_key /etc/letsencrypt/live/certificates.com/privkey.pem;

        location / {
                rewrite ^/$ /index.html;
                expires 1y;
                access_log off;
                add_header Cache-Control "max-age=31556952, public";
                proxy_pass http://minio-server/personal-website/out$uri$is_args$args;
        }

        location ^~ /.well-known/acme-challenge/ {
                alias /var/www/certbot/.well-known/acme-challenge/;
        }
}
