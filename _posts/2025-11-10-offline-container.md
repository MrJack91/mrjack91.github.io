---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---


## Intro
Vor kurzem bin ich auf `Mailpit` gestossen:
* "Mailpit - email & SMTP testing tool with API for developers"

Da ich das Tool nicht kenne, dachte ich mir:
* cool, es gibt auch ein Image
* einziges Problem: das Image könnte via Internet eine Reverse Shell öffnen

So informierte ich mich wie ich am einfachsten und saubersten einem Container das Internet verweigern kann und bin auf folgendes Setup gestossen:
* mailpit mit internal network
* Proxy wie `rinetd` (oder `socat`, `caddy`, `nginx`)


## Setup
### File Struktur
```txt
 .
├── docker-compose.yml
└── rinetd
    ├── Dockerfile
    └── rinetd.conf
```

### docker-compose.yml
```docker-compose.yml
services:
  mailpit:
    image: axllent/mailpit:latest
    hostname: mailpit
    networks:
      - internal_net
    volumes:
      - mailpit_data:/data
    environment:
      # Weist Mailpit an, diese Datei für die DB zu verwenden.
      # Mails überleben nun Container-Neustarts.
      - MP_DATA_FILE=/data/mailpit.db
      # Optional: Setzt das "Pruning" (Löschen alter Mails) hoch
      # Standard ist 1000 Mails, hier z.B. 5000
      - MP_MAX_MESSAGES=5000
    restart: unless-stopped

  proxy:
    # Baut das Image aus unserem 'rinetd'-Ordner
    build: ./rinetd
    ports:
      # Mappt Ports NUR auf localhost vom Host
      - "127.0.0.1:8025:8025"  # Host -> Proxy (Web-UI)
      - "127.0.0.1:1025:1025"  # Host -> Proxy (SMTP)
    networks:
      - default_web       # Dieses Netz hat Internet (falls nötig)
      - internal_net    # Dieses Netz verbindet zum 'mailpit'
    volumes:
      # Wir mounten unsere lokale config schreibgeschützt in den Container
      - ./rinetd/rinetd.conf:/etc/rinetd.conf:ro
    depends_on:
      - mailpit
    restart: unless-stopped

networks:
  # Das normale Netz mit Internetzugang
  default_web:
    driver: bridge
  # Das "Gefängnis" ohne Internetzugang
  internal_net:
    driver: bridge
    internal: true

volumes:
  mailpit_data:
```

### rinetd/Dockerfile
```Dockerfile
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends rinetd && \
    # Cleanup, um die Image-Größe zu minimieren
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["rinetd", "-f", "-c", "/etc/rinetd.conf"]
```

### rinetd/rinetd.conf
```conf
# rinetd/rinetd.conf
#
# Format:
# <bind_ip> <bind_port> <forward_ip> <forward_port>

# Höre auf allen IPs IM PROXY-CONTAINER auf Port 8025
# und leite an den Container 'mailpit' auf Port 8025 weiter
0.0.0.0 8025 mailpit 8025

# Dasselbe für den SMTP-Port
0.0.0.0 1025 mailpit 1025
```


## Verify
Wir nutzen eine IP anstatt DNS, um sicher zu sein, dass nicht nur DNS nicht geht.

```bash
docker compose up -d

# Beispiel wie der Proxy ins Internet kommt
docker exec -it proxy-1 bash
apt update
apt install wget

# 2x redirect, bevor dann die Adresse nicht aufgelöst werden kann. Aber Internet funktioniert.
# -S:       Show server response
# -O FILE   Save to FILE ('-' for stdout)
wget -S -O - 1.1.1.1

--2025-11-10 08:06:24--  http://1.1.1.1/
Connecting to 1.1.1.1:80... connected.
HTTP request sent, awaiting response...
  HTTP/1.1 301 Moved Permanently
  Server: cloudflare
  Date: Mon, 10 Nov 2025 08:06:24 GMT
  Content-Type: text/html
  Content-Length: 167
  Connection: keep-alive
  Location: https://1.1.1.1/
  CF-RAY: 99c40ce33c3abc41-ZRH
Location: https://1.1.1.1/ [following]
--2025-11-10 08:06:24--  https://1.1.1.1/
Connecting to 1.1.1.1:443... connected.
HTTP request sent, awaiting response...
  HTTP/1.1 301 Moved Permanently
  Date: Mon, 10 Nov 2025 08:06:24 GMT
  Content-Length: 0
  Connection: keep-alive
  Report-To: {"endpoints":[{"url":"https:\\/\\/a.nel.cloudflare.com\\/report\\/v4?s=YOXLn8lSxj90AYYJ4H0xOj51%2BgmzoAxb%2BFCrtVYPJ66tu8snF449GVnBU%2FjO2xS6Tsao%2FbcqiilCzDNeqbPy0tSqNVepjeBsgar40g57lmRY9zA2ntlaZp0%3D"}],"group":"cf-nel","max_age":604800}
  NEL: {"report_to":"cf-nel","max_age":604800}
  Location: https://one.one.one.one/
  Vary: Accept-Encoding
  Server: cloudflare
  CF-RAY: 99c40ce3e89b24bc-ZRH
Location: https://one.one.one.one/ [following]
--2025-11-10 08:06:24--  https://one.one.one.one/
Resolving one.one.one.one (one.one.one.one)... failed: Name or service not known.
wget: unable to resolve host address 'one.one.one.one'

exit


# Beispiel wie mailpit nicht mehr ins Internet kommt
docker exec -it mailpit-1 /bin/sh

# Internet geht nicht
wget -S -O - 1.1.1.1

Connecting to 1.1.1.1 (1.1.1.1:80)
wget: can't connect to remote host (1.1.1.1): Network unreachable

exit

# verify mailpit from host
echo "Yay - Mail body for offline mailpit"
curl --url 'smtp://localhost:1025' \
  --mail-from 'sender@envelope.com' \
  --mail-rcpt 'recipient@envelope.com' \
  --upload-file email.txt



```

