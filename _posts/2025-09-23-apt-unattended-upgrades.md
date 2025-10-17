---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: linux, unattended upgrades, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

Unattendend Upgrades mit Mail Notification on Ubuntu 24.04 / Debian 12

```bash
# choose app armor if asked
# mta also contains symlinks for mail, mailx, sendmail...
apt install unattended-upgrades msmtp-mta

# to enable auto upgrade
dpkg-reconfigure unattended-upgrades

# to see when updates and upgrades a triggered -> adapt them if necessary
systemctl list-timers apt-daily*


vi /etc/msmtprc

defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp

account        default
host           smtp.gmail.com
port           587
from           mail@gmail.com
user           mail@gmail.com
password       ""


# check all sources with
apt-cache policy

# nice to seperate changes
vi /etc/apt/apt.conf.d/51unattended-upgrades-my

Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,codename=${distro_codename}-updates";
        "origin=Debian,codename=${distro_codename},label=Debian";
        "origin=Debian,codename=${distro_codename},label=Debian-Security";
        "origin=Debian,codename=${distro_codename}-security,label=Debian-Security";
        
        "origin=Docker";

        // there is also support for all
        // "origin=*";
        
        // ...
};


Unattended-Upgrade::Mail "to@mail.com";
Unattended-Upgrade::MailReport "on-change";
Unattended-Upgrade::Remove-Unused-Dependencies "true";


// without this, mailx will add an own FROM (but keeps it as "Return-Path")
// if necessary, if the mail is wrong
Unattended-Upgrade::Sender "from@mail.ch";


# to test unattended, set Report to always
Unattended-Upgrade::MailReport "always";

unattended-upgrades --dry-run --debug

# ommit dry-run for testing mail send
unattended-upgrades --debug

# to test the mail config
printf "Subject: Test\n\nHello, This is my test message." | msmtp to@mail.ch
echo "Test body" | mailx -s "Test Subject" msmtp to@mail.ch
```

