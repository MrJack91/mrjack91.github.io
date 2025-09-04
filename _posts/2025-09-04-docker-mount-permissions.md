---
layout: post
title: "Docker: Mount Permissions"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

<!--
Nicest is not nice: (↪) will be with blue border
→ ⇒ ⇝ ↬
-->

## Problem
Werden Files vom Host einem Docker Container freigegeben (Volumes mount), dann gilt die User ID (UID) vom Container für die Permissions auf dem Host.

Beispiel: wenn der Container mit Root läuft, kann er auch dem Host alles lesen und neue Files erscheinen auf dem Host ebenfalls als hätte es der Host Root erstellt.

Umgekehrt, wenn im Container nicht Root verwendet wird, erfolgt Zugriff und Zugehörigkeit ebenfalls via UID vom Container.
Da oft UID 1000 für den ersten normalen User vergeben wird, kann es dort zu Überschneidungen kommen. Spätestens wenn ein Host-User als 1000 etwas freigeben will, dann ist die Versuch gross, einfach ein `chmod o+rw` zu nutzen.

Doch das muss nicht sein.

## Lösung
Umriss
* Dockerfile bleibt Root bis am Schluss
* beinhaltet einen entrypoint.sh, der:
  * user und gruppe mit gewünschter UID/GUI erstellt
  * notwendige Files diesem User zuweist
  * das eigentlich Script ausführt
* dazu verwenden wir [`gosu`](https://github.com/tianon/gosu)


`Dockerfile`
```bash
FROM ...

RUN apt update && apt install -y git gosu && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/data
WORKDIR /app/data

COPY . .

...

ENTRYPOINT ["/app/data/entrypoint.sh"]
CMD ["/bin/bash"]
```

`entrypoint.sh`
```bash
#!/bin/bash
set -e

# Default-Werte, falls nicht gesetzt
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Gruppe erstellen, falls nicht existiert
if ! getent group "$PGID" >/dev/null; then
    groupadd -g "$PGID" appgroup
fi

# User erstellen oder ändern
if ! getent passwd "$PUID" >/dev/null; then
    useradd -u "$PUID" -g "$PGID" -m -s /bin/bash appuser
else
    usermod -u "$PUID" -g "$PGID" appuser
fi

# Chown auf deine Volume-Pfade (passe /app/data an deine Mount-Points an)
chown -R "$PUID:$PGID" /app  # Hier alle relevanten Verzeichnisse auflisten

# Zum non-root User wechseln und den CMD ausführen
exec gosu "$PUID:$PGID" "$@"
```

Dann via`docker-compose.yaml` oder via `.env` kann die UID/GUI gewählt werden.

`docker-compose.yaml`
```bash
...
    # entweder direkt
    environment:
      PUID: 1000
      PGID: 1000

    # oder via .env
    environment:
      PUID: ${PUID}
      PGID: ${PGID}
```

`.env`
```bash
# rewrite project name if necessary
COMPOSE_PROJECT_NAME=test

# use id -u, id -g
PUID=1000
PGID=1000
```

Der `.env` Ansatz hat den Vorteil, dass das `docker-compose.yaml` ebenfalls in Git eingecheckt werden kann.


More Infos: [DICSAID](https://docsaid.org/en/blog/gosu-usage/)

