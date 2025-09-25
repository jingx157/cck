npx pkg cck_edition.cjs --targets node18-win-x64 --output CCKBlockerService.exe

Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.4    cck.toolpe.com"