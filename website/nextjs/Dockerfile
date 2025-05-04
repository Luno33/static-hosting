FROM node:20-alpine AS builder

WORKDIR /app

ARG ENV_FILE
COPY . .
RUN rm -f .env.local
COPY ${ENV_FILE} .env

RUN npm ci
RUN npm run build

FROM caddy:2.7.6-alpine

COPY --from=builder /app/out /srv

ARG IMAGE_URI
RUN echo "{\"image\": \"${IMAGE_URI}\"}" > /srv/version.json

RUN printf ":80 { \n\
  root * /srv \n\
  file_server \n\
  header / {\n\
    X-App-Version \"%s\"\n\
  }\n\
} \n\
:443 { \n\
  root * /srv \n\
  file_server \n\
  header / {\n\
    X-App-Version \"%s\"\n\
  }\n\
}" "$IMAGE_URI" "$IMAGE_URI" > /etc/caddy/Caddyfile

EXPOSE 80
EXPOSE 443
