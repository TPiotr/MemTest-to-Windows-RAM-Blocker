<# :
@echo off
setlocal
cd /d "%~dp0"
set "LOG_FILE=%~1"
powershell -noprofile -executionpolicy bypass "iex (${%~f0} | out-string)"
if %errorlevel% neq 0 pause
exit /b
#>

Add-Type -AssemblyName System.Windows.Forms
$f = New-Object System.Windows.Forms.OpenFileDialog

# File Selection if some file was not dropped onto the script
if ([string]::IsNullOrEmpty($env:LOG_FILE)) {
    $f.Title = "Select your MemTest86 Log File"
    $f.Filter = "Log Files (*.log)|*.log|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    if($f.ShowDialog() -eq "OK") { $logPath = $f.FileName } else { exit }
} else {
    $logPath = $env:LOG_FILE
}

Write-Host "--- Memory Log Parser & BCD Updater ---" -ForegroundColor Cyan
Write-Host "Processing: $logPath"

# Parse MemTest86 Log File
$pattern = '\[MEM ERROR - Data\].*Address: ([0-9A-F]+)'
$uniquePages = New-Object System.Collections.Generic.HashSet[string]

if (Test-Path $logPath) {
    Get-Content $logPath | ForEach-Object {
        if ($_ -match $pattern) {
            $fullAddr = $matches[1]
            if ($fullAddr.Length -ge 6) {
                $pageAddr = "0x" + $fullAddr.Substring(0, 6)
                $null = $uniquePages.Add($pageAddr)
            }
        }
    }
}

if ($uniquePages.Count -eq 0) {
    Write-Host "No memory errors found in this file." -ForegroundColor Green
    exit
}

$addressList = ($uniquePages | Sort-Object) -join " "
$count = $uniquePages.Count
Write-Host "`nFound $count unique bad memory pages." -ForegroundColor Yellow

# Limit Warning
if ($count -gt 70) {
    Write-Host "!!! WARNING !!!" -ForegroundColor Red -BackgroundColor Black
    Write-Host "You have $count bad pages. Windows often ignores lists larger than 70-100 entries, this fix may not work :(." -ForegroundColor Red
}

# Execute Commands
$cmd1 = "bcdedit /set {badmemory} badmemorylist $addressList"
$cmd2 = "bcdedit /set badmemorylist $addressList"

Write-Host "`nReady to execute both command variations:" -ForegroundColor Cyan
Write-Host "1. $cmd1" -ForegroundColor Gray
Write-Host "2. $cmd2" -ForegroundColor Gray

$confirmation = Read-Host "`nApply these fixes now? (y/n)"
if ($confirmation -eq 'y') {
    Write-Host "Applying changes (RunAs Admin)..." -ForegroundColor Yellow
    $batchScript = "$cmd1 & $cmd2 & echo. & echo SUCCESS! RESTART YOUR PC & pause"
    Start-Process cmd.exe -ArgumentList "/c $batchScript" -Verb RunAs
} else {
    Write-Host "Aborted." -ForegroundColor Red
	pause
}