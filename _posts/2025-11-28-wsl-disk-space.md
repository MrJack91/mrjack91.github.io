---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

WSL uses ext4 virtual disk which auto grows.

To reduce:
```bash
wsl.exe shutdown
```


```powershell
Optimize-VHD -Path "C:\Users\[USER]\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu24.04LTS_79rhkp1fndgsc\LocalState\ext4.vhdx" -Mode Full
```

