server {
        listen 80;
        listen [::]:80;

        root /var/www/website2.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name website2.com www.website2.com;

        location / {
                try_files $uri $uri/ =404;
        }
}