# Fresh-PC wizard: the Windows steps chezmoi apply can't do on its own (policy
# checks, admin-only settings, sign-ins). Same stage-by-stage flow as
# scripts/wizard-mac.sh. Run it from Windows PowerShell; it works before chezmoi is
# installed, so the first stages can unblock the apply:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\wizard-windows.ps1
# Every stage checks first and says so when it's already done, so a re-run is safe.

$ErrorActionPreference = 'Continue'
$script:Index = 0
$script:Skipped = New-Object System.Collections.Generic.List[string]
$TotalStages = 8

function Clear-Stage { try { Clear-Host } catch { } }
function Stage([string]$Name) {
  Clear-Stage
  $script:Index++
  Write-Host ""
  Write-Host ("> Stage {0}/{1} - {2}" -f $script:Index, $TotalStages, $Name) -ForegroundColor Blue
}
function Say([string]$Text)  { Write-Host "  $Text" }
function Step([string]$Text) { Write-Host "  * $Text" -ForegroundColor Cyan }
function Note([string]$Text) { Write-Host "  $Text" -ForegroundColor DarkGray }
function Ok([string]$Text)   { Write-Host "  OK $Text" -ForegroundColor Green }
function Warn([string]$Text) { Write-Host "  ! $Text" -ForegroundColor Yellow }
function Skip([string]$Text) { $script:Skipped.Add($Text); Warn $Text }
function Pause-Step([string]$Text = 'Press Enter to continue') { [void](Read-Host "  $Text") }
function Confirm-Step([string]$Question) { (Read-Host "  ? $Question [y/N]") -match '^[Yy]' }
function Open-Url([string]$Url) { Write-Host "  -> opening $Url" -ForegroundColor Green; Start-Process $Url }
function Test-Admin {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Clear-Stage
Write-Host ""
Write-Host "  Fresh PC: manual steps" -ForegroundColor Blue
Note "$TotalStages stages. Stop any time with Ctrl-C and re-run later."
Pause-Step 'Ready to start?'

# ── 1. Execution policy ────────────────────────────────────────────────────
Stage 'PowerShell execution policy'
Say 'chezmoi runs its .ps1 scripts with a process-scope Bypass. That works unless'
Say 'Group Policy sets MachinePolicy or UserPolicy, which overrides it.'
Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-String | Write-Host
$gpo = Get-ExecutionPolicy -List | Where-Object { $_.Scope -in 'MachinePolicy', 'UserPolicy' -and $_.ExecutionPolicy -ne 'Undefined' }
if (-not $gpo) {
  Ok 'No Group Policy override: the scripts can run.'
} elseif ($gpo.ExecutionPolicy -contains 'Restricted' -or $gpo.ExecutionPolicy -contains 'AllSigned') {
  Skip "Group Policy sets the execution policy to $($gpo.ExecutionPolicy -join ', '). Ask IT for RemoteSigned or an exception; chezmoi's scripts can't run until then."
} else {
  Ok "Group Policy sets $($gpo.ExecutionPolicy -join ', '), which lets local scripts run."
}
Pause-Step

# ── 2. winget and the Store source ─────────────────────────────────────────
Stage 'winget and the Microsoft Store source'
if (Get-Command winget -ErrorAction SilentlyContinue) {
  Ok "winget $(winget --version)"
  $sources = winget source list 2>$null | Out-String
  if ($sources -match 'msstore') { Ok 'The msstore source is available (ChatGPT comes from it).' }
  else { Skip 'The msstore source is missing or blocked: install ChatGPT by hand, or ask IT.' }
} else {
  Skip 'winget is missing: install "App Installer" from the Microsoft Store, then re-run this wizard.'
  Open-Url 'ms-windows-store://pdp/?productid=9NBLGGH4NNS1'
}
Pause-Step

# ── 3. OpenSSH client ──────────────────────────────────────────────────────
Stage 'OpenSSH client'
Say 'Windows Terminal, VS Code Remote and git over SSH use the built-in ssh.exe.'
if (Get-Command ssh.exe -ErrorAction SilentlyContinue) {
  Ok "ssh.exe found: $((Get-Command ssh.exe).Source)"
} else {
  Step 'Settings -> System -> Optional features -> View features -> "OpenSSH Client" -> Install.'
  Open-Url 'ms-settings:optionalfeatures'
  Note 'If the feature list is locked, IT has removed it: ask them to add OpenSSH.Client.'
  Pause-Step 'Installed? Press Enter to check.'
  if (Get-Command ssh.exe -ErrorAction SilentlyContinue) { Ok 'ssh.exe found' } else { Skip 'OpenSSH client still missing (open a new terminal and check ssh -V)' }
}
Pause-Step

# ── 4. chezmoi apply ───────────────────────────────────────────────────────
Stage 'chezmoi apply'
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
  if (Confirm-Step 'Install chezmoi with winget now?') {
    winget install --id twpayne.chezmoi --exact --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
  }
}
if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
  Say 'The first apply asks for your name, emails and the machine type (pick "work"),'
  Say 'then installs the apps (one UAC prompt) and writes the configs.'
  if (Confirm-Step 'Run chezmoi init --apply lplatzer/dotfiles now? (Re-running is safe.)') {
    chezmoi init --apply lplatzer/dotfiles
    if ($LASTEXITCODE -ne 0) { Skip "chezmoi apply exited with $($LASTEXITCODE): scroll up for the failing step, fix it, run chezmoi apply again" }
  } else { Skip 'chezmoi init --apply lplatzer/dotfiles' }
} else {
  Skip 'chezmoi is not installed (winget install twpayne.chezmoi)'
}
Pause-Step

# ── 5. Claude desktop WSL policy ───────────────────────────────────────────
Stage 'Claude desktop: WSL sessions policy'
Say 'Claude desktop reaches the dev environment in WSL. An admin policy can turn that off:'
Note 'HKLM\SOFTWARE\Policies\Claude  disableWslSessions'
$policy = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Claude' -Name 'disableWslSessions' -ErrorAction SilentlyContinue
if (-not $policy) {
  Ok 'Not set: WSL sessions are allowed.'
} elseif ($policy.disableWslSessions -eq 0) {
  Ok 'Set to 0: WSL sessions are allowed.'
} else {
  Warn "Set to $($policy.disableWslSessions): WSL sessions are disabled."
  if ((Test-Admin) -and (Confirm-Step 'Set it to 0 now (you are running as admin)?')) {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Claude' -Name 'disableWslSessions' -Value 0 -Type DWord
    Ok 'Set to 0. Restart Claude desktop.'
  } else {
    Skip 'Claude WSL sessions are disabled by policy: ask IT to set HKLM\SOFTWARE\Policies\Claude\disableWslSessions to 0 (or remove it)'
  }
}
Pause-Step

# ── 6. Sign-ins and licences ───────────────────────────────────────────────
Stage 'Sign-ins and licences'
Say 'Open each app once and sign in. They are all in the Start menu after the apply.'
Step 'Claude: sign in with your work account.'
Step 'ChatGPT: sign in; for Codex, Settings -> agent environment -> WSL if you work in WSL.'
Step 'superwhisper: sign in (one licence covers Mac and Windows).'
Step 'Logi Options+: pair the mouse; Keymapp: connect the keyboard once.'
Step 'PowerToys: Settings -> Command Palette -> enabled (Win+Alt+Space replaces Alfred).'
Pause-Step

# ── 7. GlazeWM ─────────────────────────────────────────────────────────────
Stage 'GlazeWM: start at login and test the Hyper key'
$startup = Join-Path ([Environment]::GetFolderPath('Startup')) 'GlazeWM.lnk'
$glaze = Get-Command glazewm -ErrorAction SilentlyContinue
if (-not $glaze) { $glaze = Get-ChildItem "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe", "$env:LOCALAPPDATA\Programs\glzr.io\GlazeWM\glazewm.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (Test-Path $startup) {
  Ok 'GlazeWM already starts at login.'
} elseif ($glaze -and (Confirm-Step 'Start GlazeWM at login (shortcut in your Startup folder)?')) {
  $target = if ($glaze.Source) { $glaze.Source } else { $glaze.FullName }
  $lnk = (New-Object -ComObject WScript.Shell).CreateShortcut($startup)
  $lnk.TargetPath = $target
  $lnk.Save()
  Ok "Startup shortcut created ($target)"
  Start-Process $target
} elseif (-not $glaze) {
  Skip 'GlazeWM not found: rerun chezmoi apply (winget glzr-io.glazewm)'
}
Say 'Test the Hyper key (Ctrl+Alt+Win from the thumb key):'
Step 'Hyper+H/J/K/L moves focus, Hyper+1..0 switches workspace, Hyper+Enter opens Terminal.'
Step 'Hyper+Shift+L should move a window right. If LinkedIn or Office opens instead, the'
Step 'Office-key chord (Ctrl+Alt+Shift+Win) is grabbing it.'
Note 'Escape hatch: Hyper+Shift+P pauses all GlazeWM bindings.'
if (Confirm-Step 'Did Office or LinkedIn open?') {
  Note 'Community fix (unverified by Microsoft): point the ms-officeapp handler at a no-op, per user.'
  if (Confirm-Step 'Apply it now (HKCU, no admin; undo by deleting HKCU\Software\Classes\ms-officeapp)?') {
    New-Item -Path 'HKCU:\Software\Classes\ms-officeapp\Shell\Open\Command' -Force | Out-Null
    Set-ItemProperty -Path 'HKCU:\Software\Classes\ms-officeapp\Shell\Open\Command' -Name '(default)' -Value 'rundll32'
    Ok 'Applied. Sign out and in, then test Hyper+Shift+L again and note the result in WS-33.'
  } else { Skip 'Office-key chord still collides with Hyper+Shift (WS-33)' }
}
Pause-Step

# ── 8. Keyboard layouts ────────────────────────────────────────────────────
Stage 'Keyboard layouts'
Say 'The MSKLC-built installers for lplatzer-layout and EnDeu-Y-ISO come from WS-29,'
Say 'which has not delivered them yet. Once it has, the Windows host script runs them.'
Note 'Until then: nothing to do here.'
Pause-Step

# ── Summary ────────────────────────────────────────────────────────────────
Clear-Stage
Write-Host ""
Write-Host '  Done' -ForegroundColor Green
if ($script:Skipped.Count) {
  Warn 'Still to do by hand:'
  $script:Skipped | ForEach-Object { Note "  - $_" }
}
Write-Host ""
