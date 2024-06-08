FROM caddy:2.7.6-alpine

COPY ./out /srv
RUN echo -e ":80 { \n\
  root * /srv \n\
  file_server \n\
} \n\
:443 { \n\
  root * /srv \n\
  file_server \n\
}" > /etc/caddy/Caddyfile

EXPOSE 80
EXPOSE 443
