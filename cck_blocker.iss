#define MyAppName "CCK Blocker"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Your Company"
#define MyAppExeName "CCKBlockerService.exe"
#define MyServiceName "CCKBlockerService"
#define MyFirewallRule "CCK Blocker HTTP"

[Setup]
AppId={{2F9B7D89-3BBA-4F1C-9F50-51B6C0CECCKB}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={pf}\{#MyAppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputBaseFilename=CCK-Blocker-Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64os
WizardStyle=modern

[Files]
; Bundle your packaged Node EXE
Source: "{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; 1) Add hosts entry (idempotent) + flush DNS
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$p = '$env:WINDIR\System32\drivers\etc\hosts'; $c = Get-Content -Path $p -Encoding ASCII; if (-not ($c -match '^\s*127\.0\.0\.1\s+cck\.toolpe\.com\s*$')) {{ Add-Content -Path $p -Value '127.0.0.1 cck.toolpe.com' -Encoding ASCII }}; ipconfig /flushdns | Out-Null"""; \
  StatusMsg: "Configuring hosts file..."; Flags: runhidden

; 2) Open Windows Firewall for inbound TCP:80 (idempotent)
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""If(-not (Get-NetFirewallRule -DisplayName '{#MyFirewallRule}' -ErrorAction SilentlyContinue)) {{ New-NetFirewallRule -DisplayName '{#MyFirewallRule}' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 | Out-Null }}"""; \
  StatusMsg: "Configuring Windows Firewall..."; Flags: runhidden

; 3) Create Windows service if it doesn't exist
Filename: "sc.exe"; Parameters: "create {#MyServiceName} binPath= ""{app}\{#MyAppExeName}"" start= auto DisplayName= ""{#MyAppName}"""; \
  StatusMsg: "Creating Windows service..."; Flags: runhidden; Check: not ServiceExists('{#MyServiceName}')

; 4) Start service
Filename: "sc.exe"; Parameters: "start {#MyServiceName}"; StatusMsg: "Starting service..."; Flags: runhidden

[UninstallRun]
; Stop service (ignore errors if not running)
Filename: "sc.exe"; Parameters: "stop {#MyServiceName}"; Flags: runhidden

; Delete service
Filename: "sc.exe"; Parameters: "delete {#MyServiceName}"; Flags: runhidden

; Remove hosts entry safely + flush DNS
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$p = '$env:WINDIR\System32\drivers\etc\hosts'; (Get-Content $p -Encoding ASCII) | Where-Object {{ $_ -notmatch '^\s*127\.0\.0\.1\s+cck\.toolpe\.com\s*$' }} | Set-Content $p -Encoding ASCII; ipconfig /flushdns | Out-Null"""; \
  Flags: runhidden

; Remove firewall rule if present
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$r = Get-NetFirewallRule -DisplayName '{#MyFirewallRule}' -ErrorAction SilentlyContinue; if($r){{ $r | Remove-NetFirewallRule }}"""; \
  Flags: runhidden

[Code]
function ServiceExists(ServiceName: string): Boolean;
var
  ResultCode: Integer;
begin
  Result := (ShellExec('', 'sc.exe', 'query ' + ServiceName, '', SW_HIDE, ewWaitUntilTerminated, ResultCode)) and (ResultCode = 0);
end;