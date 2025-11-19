---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: cisco, vpn, wsl
# meta: "Springfield"
# modified_date: 2016-05-27
published: True
# excerpt_separator: <!--end_excerpt-->
---

Via VPN kann WSL nicht mehr auf die lokalen Ressourcen zugreifen.

## Problem
Sobald man via VPN verbunden ist (z.B. Cisco AnyConnect) können im WSL keine IP's mehr angepinnt werden. Timeout.
Ohne VPN (im lokalen Netz) funktioniert alles.

## Lösung
Stelle den Network Mode von WSL auf `mirrored`. Z.B. via WSL Settings.


## Alternative - z.B. um etwas zu lernen

### Ursache
Für ein Ziel kann mehr als ein Route bekannt sein.
Ist dies der Fall, wählt Windows anhand der Kosten (`TotalMetric = InterfaceMetric + RouteMetric`), die Verbindung mit den geringsten Kosten.
* `InterfaceMetric`: „Grund-Priorität“ einer Netzwerkkarte
* `RouteMetric`: Route spezifische Priorität


```powershell
# display all adapters / interaces
Get-NetAdapter

# print all network interfaces with useful properties
Get-NetIPInterface | Sort InterfaceMetric | Format-Table -AutoSize `
    InterfaceAlias,      # z.B. "Ethernet 7"
    InterfaceMetric,     # 5 = sehr hoch, 6000 = sehr niedrig
    AddressFamily,       # IPv4 oder IPv6
    @{Name="Beschreibung"; Expression={(Get-NetAdapter -InterfaceIndex $_.InterfaceIndex).InterfaceDescription}},
    @{Name="AdapterName";  Expression={(Get-NetAdapter -InterfaceIndex $_.InterfaceIndex).Name}},
    ConnectionState,     # Up / Disconnected / Not Present
    Dhcp                 # Enabled / Disabled

```

* Der VPN-Client fügt einen virtuelles Interface mit einer `InterfaceMetric=1` ein. So dass jegliche Verbindungen via VPN laufen.
* WSL2 (mit Hyper-V) hat aber eigene Interfaces mit `InterfaceMetric=5000`.
* Nach meinem Verständnis, geht das VPN nur direkt vom Windows Host und nicht direkt vom WSL.
* Darum muss WSL weiterhin das WSL Interface verwenden.
* Das geht z.B. indem man für das VPN Interface die `InterfaceMetric=6000` setzt.
    ```powershell
    Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Cisco*"} | Set-NetIPInterface -InterfaceMetric 6000
    ```
* Diese Option ist nicht persistent, kann wenn nötig automatisch gesetzt werden.

