---
layout: post
title: "Some articles are just so short that we have to make the footer stick"
categories: misc
author:
- Bart Simpson
- Nelson Mandela Muntz
meta: "Springfield"
modified_date: 2016-05-27
---

# Struct
- Zertifikate
- bei SAP HANA
- Store fürs hdbcli und HDBC
- Management Windows
- Management Linux


# Summary
- We manage to use an internal signed cert
- windows is using mostly the internal cert store, so this should work everywhere
- linux must reference the internal ca pem/crt
- dbeaver is using the internal cert store by default
- pycharm, needs to set an vm option to use the windows store or needs the link to the jks
- jdbc and hdbcli (also used by sqlalchemy) is fully different
  - jdbc manage own certs or can use a cert provider on windows. on linux certs will be combined in `/etc/ssl/certs/java/cacerts` (using `ca-certificates-java`)
  - hdbcli needs certs store (mscrypto) on windows. on linux we can link: `/etc/ssl/certs/ca-certificates.crt` -> containing all host certs.


```bash
whoami
grep -rin hallihallo
```


