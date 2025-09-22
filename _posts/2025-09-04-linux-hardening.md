---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: linux, hardening, server
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

test abc

<!--
Nicest is not nice: (↪) will be with blue border
→ ⇒ ⇝ ↬
-->

test

## General

Paar Schritte um einen Linux Server grob zu checken:
```bash
# liste alle Port die zurzeit offen sind (optional: interne können augeschlossen werden)
ss -tulpen | grep -v 127.0.0.1

# liste alle sockets, die unteranderem auch einen Port öffnen können
systemctl list-sockets

# ↬ unten paar typische Service, die noch aktiviert sein könnten.

ufw ...

# auto upgrades, mind. für Security patches
dpkg-reconfigure unattended-upgrades
systemctl edit apt-daily-upgrade.timer

```

## SSH
```bash
PasswordAuthentication no
PermitRootLogin no
AllowGroups ssh-user

# disable
X11Forwarding no
AllowTcpForwarding no
PermitTunnel no
```

## Image
Falls das zur Verfügung gestellt Image bereits upgrades durchgemacht hat:
```bash
# list configs die noch übrig sind
apt list | grep "\[residual-config\]"
```

## Penetration Test
* bei Bedarf das [LinPeas](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS) ausführen.


## Auswertung der offenen Ports / Sockets

### chrony (0.0.0.0:123/udp)
Wenn der Server nur Zeitbeziehen will, aber nicht anderen Zeitsynchronisierung anbieten soll:
```bash
vi /etc/chrony/chrony.d/my.conf
# add
port 0

sudo systemctl restart chronyd

# to check
chronyc tracking
chronyc makestep
timedatectl
```

### exim4 (127.0.0.1:25/tcp)
Wenn man sowieso externe Mail-Server braucht:
```bash
systemctl stop exim4
systemctl disable exim4
systemctl status exim4
sudo apt purge exim4 exim4-base exim4-config exim4-daemon-light
```

### systemd resolved
(127.0.0.54:53/udp/tcp) / LLMNR (0.0.0.0:5355/udp/tcp)

#### DNS (127.0.0.54:53/udp/tcp)
Wird als interner DNS Cache verwendet, daher so lassen.

#### LLMNR (0.0.0.0:5355/udp/tcp)
LLMNR (Link-Local Multicast Name Resolution) ist bei normalen Netzwerken nicht nötig.

```bash
vi /etc/systemd/resolved.conf
[Resolve]
LLMNR=no

sudo systemctl restart systemd-resolved
```

