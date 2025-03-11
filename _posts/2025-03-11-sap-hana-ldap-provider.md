---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
# published: false
# excerpt_separator: <!--end_excerpt-->
---

Den Active Directory Account für die Verbindung zur DB (SAP HANA) verwenden, why not?


## Intro
### Painpoints
- Die DBA's lassen uns keine DB-User erstellen. D.h. wir müssen für jeden neuen User, ein Ticket erstellen, so dass der DBA uns einen neuen User erstellt.
- Aktuelle User haben ein eigenes Passwort für ihren DB-User.

### Vorteile
- **zentrales Login**
  - die Logins werden zentral erstellt
  - die Logins werden zentral deaktiviert
  - die Permissions werden zentral verwaltet
- **automatische User Erstellung**
  - Für neue User, kann alles vorbereitet werden. Der User wird erstellt, sobald sich der User das erste Mal anmeldet. --> Dieses Problem könnte auch via Permissions oder mit einem custom Package behoben werden.

### Nachteile
- DB Login wird meist plaintext oder sehr einfach verschlüsselt gespeichert (Scripts, DB Tools), wenn das dem AD Account entspricht, kann dieses so rausgefunden werden.
- Bei dem regelmässigen Passwort-Wechsel, kann es dazu kommen, dass der User sicher selbst aussperrt (Lockout).
- Bei einem Lockout wird das gesamte Windows gesperrt.

### Outcome
Wir verwenden das AD-Login auf Grund dieser Nachteilen nicht.


## How to
So würde es funktionieren:
- Names definieren
    - **AD_HANA_SERVICE_USER:** AD Service User der für LDAP verwendet werden soll.
    - **AD_PERMISSION_GROUP_ALLOW_CONNECT:** wie oben erwähnt pro Umgebung
    - Berechtigungsgruppen nach Bedarf:
      - Beispiel: **AD_P_DB_Consumer**
- AD Gruppen definieren
    - Versch. Umgebungen verwalten (Dev, Test, Prod)
        - eigene Gruppe pro Umgebung
    - AD Gruppen verwalten lassen
        - wenn nötig eigene AD Gruppe erstellen, welche die User den Business Gruppen zuweisen darf.
- LDAP Root Zertifkate laden
    - [LDAP Based Authentication for SAP HANA 2.0](https://community.sap.com/t5/technology-blogs-by-members/ldap-based-authentication-for-sap-hana-2-0/ba-p/13404979)
- SQL
    - LDAP Provider erstellen
    - Gruppen mappen
    - Permissions für neue Gruppen setzen
    - User mit LDAP erstellen
    - Existierende Users migrieren


### LDAP Syntax Beispiele
```
# Search for user
(cn=*<USERNAME>*)

# list all effective groups of a specific user:
(member:1.2.840.113556.1.4.1941:=CN=<USERNAME>,OU=Admin,OU=Users,OU=myOu,DC=ms,DC=company,DC=com)

# list all direct groups of a specific user:
(member:CN=<USERNAME>,OU=Admin,OU=Users,OU=myOu,DC=ms,DC=company,DC=com)
```


### SQL
```sql
-- create the ldap provider
-- doc: https://help.sap.com/docs/SAP_HANA_PLATFORM/4fe29514fd584807ac9f2a04f6754767/ae9ba28ddefc4b29809d5b926d6ee02d.html
ALTER LDAP PROVIDER my_ldap
    CREDENTIAL TYPE 'PASSWORD' USING 'user=CN=<AD_HANA_SERVICE_USER>,OU=Service,OU=Users,OU=myOu,DC=ms,DC=company,DC=com;password=xx'

    -- which users are allowed for user creation -> * will be replaced with username
    USER LOOKUP URL 'ldaps://ad.ms.company.com/OU=myOu,DC=ms,DC=uhbs,DC=ch??sub?(&(objectClass=user)(memberOf:1.2.840.113556.1.4.1941:=CN=<AD_PERMISSION_GROUP_ALLOW_CONNECT>,OU=Permission,OU=Groups,OU=myOu,DC=ms,DC=company,DC=com)(sAMAccountName=*))'

    -- use all groups from this "myOu"
    NESTED GROUP LOOKUP URL 'ldaps://ad.ms.company.com/OU=myOu,DC=ms,DC=uhbs,DC=ch??sub?(&(objectClass=group)(memberOf:1.2.840.113556.1.4.1941:=OU=Permission,OU=Groups,OU=myOu,DC=ms,DC=company,DC=com)(member:1.2.840.113556.1.4.1941:=*))'

    ATTRIBUTE DN 'distinguishedName'
    
    -- not needed if "NESTED GROUP LOOKUP URL" is set
    -- ATTRIBUTE MEMBER_OF 'memberOf'
    
    -- we use ldaps, so ssl should be disabled
    SSL OFF
    
    -- use this as the default provider -> useful in combination with user creation below
    DEFAULT ON

    -- enable it
    ENABLE PROVIDER

    -- allow user creation for users while first login
    ENABLE USER CREATION FOR LDAP USER TYPE STANDARD
;

-- validate user and password query
VALIDATE LDAP PROVIDER my_ldap;
VALIDATE LDAP PROVIDER my_ldap CHECK USER <AD_USER>;
VALIDATE LDAP PROVIDER my_ldap CHECK USER <AD_USER> PASSWORD <AD_USER_PASSWORD>;


-- create roles (groups in hana) accordingly
-- create the 1:1 role according to the AD-group
CREATE ROLE cdwh.AD_P_DB_Consumer
    LDAP GROUP 'CN=AD_P_DB_Consumer,OU=Permission,OU=Groups,OU=groupsOU,DC=ms,DC=company,DC=com';

-- create an abstract role, to also support non-AD users
create role cdwh.CONSUMER;
-- give the AD-role the consumer grants
grant cdwh.CONSUMER to cdwh.AD_P_DB_Consumer;


-- grant now all permission on
grant select, select metadata on schema xy to cdwh.CONSUMER;


-- create new users with ldap provideer
CREATE USER <USERNAME> AUTHORIZATION LDAP;


-- or migrate existing local user to ldap provider
ALTER USER <USERNAME> DISABLE PASSWORD
ALTER USER <USERNAME> ENABLE LDAP;
ALTER USER <USERNAME> AUTHORIZATION LDAP;

-- or to revert to the original password before
ALTER USER <USERNAME> DISABLE LDAP;
ALTER USER <USERNAME> ENABLE PASSWORD;
ALTER USER <USERNAME> AUTHORIZATION LOCAL;


-- debug: special permissions like reading masked fields can be cached if testing AD, clean cache
ALTER SYSTEM CLEAR SQL PLAN CACHE;
ALTER SYSTEM CLEAR CACHE ( <cache_id> [, <cache_id> […] ] [ SYNC ] );
```

### HANA System Tables
- sys.users
- sys.ldap_providers
- sys.granted_roles
- sys.granted_privileges



## Weitere Infos
- Gruppenzugehörigkeiten eines Users wird beim Login des Users evaluiert.
  - Standardmässig nur: wenn die letzte Evaluierung älter als 4h ist.
  - [Role Reuse Duration- LDAP Group Authorization](
https://help.sap.com/docs/hana-cloud-database/sap-hana-cloud-sap-hana-database-security-guide/ldap-group-authorization#role-reuse-duration)
- [CREATE LDAP PROVIDER Statement (Access Control)](https://help.sap.com/docs/SAP_HANA_PLATFORM/4fe29514fd584807ac9f2a04f6754767/3b722036ba4941df8712508a3b231643.html?locale=en-US)
- [CREATE ROLE Statement (Access Control)](https://help.sap.com/docs/SAP_HANA_PLATFORM/4fe29514fd584807ac9f2a04f6754767/20d4a23b75191014a182b123906d5b16.html?locale=en-US)
- [LDAP User Authentication](https://help.sap.com/docs/SAP_HANA_PLATFORM/b3ee5778bc2e4a089d3299b82ec762a7/868f8b988e2d42ccb89ccaf263cd9986.html)
- [Configure LDAP Authentication and Authorization](https://help.sap.com/docs/SAP_HANA_PLATFORM/6b94445c94ae495c83a19646e7c3fd56/e98656353a694483a924d09c61a3c76d.html)
- [LDAP Provider Configuration (Reference)](https://help.sap.com/docs/SAP_HANA_PLATFORM/6b94445c94ae495c83a19646e7c3fd56/b8406c6e363747dea9098f00648d15b5.html)
- [LDAP Based Authentication for SAP HANA 2.0 - BLOG mit Certs](https://community.sap.com/t5/technology-blogs-by-members/ldap-based-authentication-for-sap-hana-2-0/ba-p/13404979)
