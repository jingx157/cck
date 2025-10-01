#define MyAppName "CCK Blocker"
#define MyAppVersion "2.0.0"
#define MyAppPublisher "Google"
#define MyAppExeName "CCKBlockerService.exe"
#define MyServiceName "CCKBlockerService"
#define MyFirewallRule "CCK Blocker HTTP"

[Setup]
; Use a real GUID you generate once and never change
AppId={{2F9B7D89-3BBA-4F1C-9F50-51B6C0CECC0B}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={pf64}\{#MyAppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputBaseFilename=CCK-Blocker-Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern

[Files]
Source: "{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; 1) Add hosts entry (idempotent) + flush DNS
Filename: "cmd.exe"; \
  Parameters: "/c findstr /R /C:""^127\.0\.0\.4 cck\.toolpe\.com$"" ""%WINDIR%\System32\drivers\etc\hosts"" >NUL || (attrib -r ""%WINDIR%\System32\drivers\etc\hosts"" 2>NUL & echo 127.0.0.4 cck.toolpe.com>>""%WINDIR%\System32\drivers\etc\hosts"" & ipconfig /flushdns >NUL)"; \
  StatusMsg: "Configuring hosts file..."; \
  Flags: runhidden

; 2) Open Windows Firewall for inbound TCP:80 (idempotent)
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$rule = Get-NetFirewallRule -DisplayName '{#MyFirewallRule}' -ErrorAction SilentlyContinue; if(-not $rule) {{ New-NetFirewallRule -DisplayName '{#MyFirewallRule}' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 -Profile Any | Out-Null }}"""; \
  StatusMsg: "Configuring Windows Firewall..."; Flags: runhidden

; 3) Register startup task (runs as SYSTEM, highest privilege, at boot)
Filename: "schtasks.exe"; \
  Parameters: "/Create /TN {#MyServiceName} /TR ""\""{app}\{#MyAppExeName}\"""" /SC ONSTART /RU SYSTEM /RL HIGHEST /F"; \
  StatusMsg: "Registering startup task..."; Flags: runhidden

; 4) Start immediately without reboot
Filename: "schtasks.exe"; Parameters: "/Run /TN {#MyServiceName}"; \
  StatusMsg: "Starting background task..."; Flags: runhidden

[UninstallRun]
; Stop and delete the scheduled task
Filename: "schtasks.exe"; Parameters: "/End /TN {#MyServiceName}"; Flags: runhidden
Filename: "schtasks.exe"; Parameters: "/Delete /TN {#MyServiceName} /F"; Flags: runhidden

; Remove hosts entry + flush DNS
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$p = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'; (Get-Content $p -Encoding ASCII) | Where-Object {{ $_ -notmatch '^\s*127\.0\.0\.4\s+cck\.toolpe\.com\s*\r?$' }} | Set-Content $p -Encoding ASCII; ipconfig /flushdns | Out-Null"""; \
  Flags: runhidden

; Remove firewall rule if present
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$r = Get-NetFirewallRule -DisplayName '{#MyFirewallRule}' -ErrorAction SilentlyContinue; if($r){{ $r | Remove-NetFirewallRule }}"""; \
  Flags: runhidden
