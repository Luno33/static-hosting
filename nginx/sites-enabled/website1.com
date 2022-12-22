server {
        listen 80;
        listen [::]:80;

        root /var/www/website1.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name website1.com www.website1.com;

        location / {
                try_files $uri $uri/ =404;
        }
}
