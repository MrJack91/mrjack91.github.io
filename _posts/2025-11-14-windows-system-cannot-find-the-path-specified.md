---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

> "The system cannot find the path specified."
> - Powershell, before every command I want to run

# Background
Als [pixi](https://pixi.sh/) und PyCharm Nutzer, wollte ich die Erweiterung `pixi-pycharm` verwenden, um `pixi` [ins Pycharm zu integrieren][https://pixi.sh/dev/integration/editor/jetbrains/].

Jedoch erhielt ich nach der Auswahl der `conda.bat` beim Reload der Environemts immer die Meldung:
> "The system cannot find the path specified."

Ich verdächtigte: pycharm, pixi, pixi-pycharm.

# Lösung
Bei der Analyse von `conda.bat` (was nicht grosses macht), bermekte ich das vor jedem command in der PowerShell diese Meldung erscheint.

Mit Hilfe dieses Scripts (merci, AI) findet man invalide Path Variablen, die von früher sind und immer zu diesem Fehler führen.
Entweder im Path oder in der Registry.

```powershell
Write-Host "=== Checking PATH entries ===" -ForegroundColor Cyan
$paths = $env:PATH -split ';'
foreach ($p in $paths) {
    if (-not $p) {
        Write-Host "[EMPTY] <empty entry>" -ForegroundColor Yellow
    } elseif (-not (Test-Path $p)) {
        Write-Host "[INVALID] $p" -ForegroundColor Red
    }
}

Write-Host "`n=== Checking AutoRun registry keys ===" -ForegroundColor Cyan
$keys = @(
    "HKCU:\Software\Microsoft\Command Processor",
    "HKLM:\Software\Microsoft\Command Processor"
)

foreach ($k in $keys) {
    try {
        $val = (Get-ItemProperty $k -Name AutoRun -ErrorAction Stop).AutoRun
        Write-Host "[FOUND] $k → $val" -ForegroundColor Yellow
    } catch {
        Write-Host "[OK] $k → no AutoRun" -ForegroundColor Green
    }
}

```

