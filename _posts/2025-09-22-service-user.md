---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: linux, user, permission, service account, systemd
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

So kann man Systemd User Services mit minimalem User laufen lassen.

# Intro

Service Accounts können ganz divers aufgesetzt werden:
- `adduser --system`: wirklich minimaler User
- `adduser --disabled-login`: keine shell
- `adduser --disabled-password`: kein PW (`passwd -l`)

Sobald man Systemd User Service verwalten will und die Logs einfach sehen können, ist es am einfachsten wenn man `systemctl` und `journalctl` direkt als Service ausführender User aufrufen kann.

Darum erlaube ich eine Shell, will aber kein SSH-Access erlauben und muss daher die XDG_RUNTIME_DIR setzen.


```bash
sudo adduser --disabled-password --comment "" [service-name]
sudo addgroup [admin-service-group]
sudo usermod -aG [admin-service-group] [service-name]
sudo usermod -aG docker [service-name]

vi /etc/sudoers.d/[admin-service-group]
  %[admin-service-group]   ALL=(ALL:ALL) NOPASSWD: ALL

chsh -s /usr/bin/fish [service-name]

loginctl enable-linger [service-name]

# use to get <service-name> shell
sudo -i -u [service-name]


vi .config/fish/config.fish
  set -x XDG_RUNTIME_DIR /run/user/(id -u)
vi .bashrc
  export XDG_RUNTIME_DIR=/run/user/$UID

# if the service needs python / pixi -> install it per service, it's much easier then a shared setup
curl -fsSL https://pixi.sh/install.sh | bash

systemctl --user daemon-reload
systemctl --user list-unit-files | grep [service-name]
systemctl --user enable --now [service-name]
```

