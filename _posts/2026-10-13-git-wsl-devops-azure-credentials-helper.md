---
layout: post
title: "Azure DevOps Git Credentials Manager für WSL"
categories: wsl, git, git-credential-manager, azure, devops
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
excerpt_separator: <!--end_excerpt-->
---

WSL richtig und sicher mit Git auf DevOps Azure verbinden.

<!--end_excerpt-->

DevOps hat nur RSA Keys um per SSH Repos zu laden.

Darum besser den Credential Manager nutzen.


Siehe: [wsl-git](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-git)


WSL (Ubuntu) hat git bereits installiert (ohne credential Manager), diesen kann man auf das Windows Exe hängen.
```bash

git config --global credential.helper "/mnt/c/Progra~1/Git/mingw64/bin/git-credential-manager.exe"
git config --global credential.useHttpPath true
git config --global credential.azreposCredentialType oauth

# nicht erschrecken, dies failed, weil der credential-manager so nicht existiert.
git credential-manager --version

# das geht aber und er verwendet die existierenden Token von Windows
git clone https://xxx@dev.azure.com/xxx/my/_git/xx
```
