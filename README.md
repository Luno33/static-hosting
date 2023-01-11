# Static Hosting

## Create a self-signed certificate

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./self-signed/private/nginx-selfsigned.key -out ./self-signed/certs/nginx-selfsigned.crt
```

change it to be readable (needed on the Ubuntu VPS)

```
sudo chmod +x ./self-signed/private/nginx-selfsigned.key
```

## Prerequisites to obtain a certificate

### Email

You need to set up an email that will be used by let's encrypt to send you notification about your certificate.
Apparently is an optional parameter since it's not mentioned here: https://eff-certbot.readthedocs.io/en/stable/install.html#running-with-docker

If you want to set it up:

```bash
export ACME_EMAIL="--email your@email.com" 
```

If you don't want to set it up:

```bash
export ACME_EMAIL="" 
```

### Domains

These are the domains for which certbot will request a certificate:

```bash
export ACME_DOMAINS="-d DOMAIN1.com -d DOMAIN2.com"
```

---

## Run container to request certificates

```
docker compose -f certbot-docker-compose.yml up
```

with just an all-in-one command

```
ACME_EMAIL="" ACME_DOMAINS="-d DOMAIN1.com -d DOMAIN2.com" docker compose -f certbot-docker-compose.yml up
```
