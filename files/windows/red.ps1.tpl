
# Set logfile and function for writing logfile
$logfile = "C:\Terraform\red_log.log"
Function lwrite {
    Param ([string]$logstring)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logstring = "$timestamp $logstring"
    Add-Content $logfile -value $logstring
}
lwrite("Starting red.ps1")

# Download PurpleSharp
if (Test-Path -Path "C:\tools") {
  lwrite("C:\tools exists")
} else {
  lwrite("Creating C:\tools")
  New-Item -Path "C:\tools" -ItemType Directory
}

# Turn off Defender realtime protection so tools can download properly
Set-MpPreference -DisableRealtimeMonitoring $true
# Set AV exclusion path so red team tools can run 
Set-MpPreference -ExclusionPath "C:\Tools" 

# Download PurpleSharp
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0

if (Test-Path -Path "C:\tools\PurpleSharp.exe") {
  lwrite("C:\tools\PurpleSharp.exe exists")
} else {
  while ($Attempt -lt $MaxAttempts) {
    $Attempt += 1
    lwrite("Attempt: $Attempt")
    try {
        Invoke-WebRequest -Uri "https://github.com/mvelazc0/PurpleSharp/releases/download/v1.3/PurpleSharp_x64.exe" -OutFile "C:\tools\PurpleSharp.exe" -TimeoutSec $TimeoutSeconds
        lwrite("Successful")
        break
    } catch {
        if ($_.Exception.GetType().Name -eq "WebException" -and $_.Exception.Status -eq "Timeout") {
            lwrite("Connection timed out. Retrying...")
        } else {
            lwrite("An unexpected error occurred:")
            lwrite($_.Exception.Message)
            break
        }
    }
  }
  if ($Attempt -eq $MaxAttempts) {
    Write-Host "Reached maximum number of attempts. Continuing..."
  }
}

# Get atomic red team (ART)
lwrite("Downloading Atomic Red Team")
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0

if (Test-Path -Path "C:\Tools\atomic-red-team-master.zip") {
  lwrite("C:\Tools\atomic-red-team-master.zip exists")
} else {
  while ($Attempt -lt $MaxAttempts) {
    $Attempt += 1
    lwrite("Attempt: $Attempt")
    try {
        Invoke-WebRequest -Uri "https://github.com/redcanaryco/atomic-red-team/archive/refs/heads/master.zip" -OutFile "C:\Tools\atomic-red-team-master.zip" -TimeoutSec $TimeoutSeconds
        lwrite("Successful")
        break
    } catch {
        if ($_.Exception.GetType().Name -eq "WebException" -and $_.Exception.Status -eq "Timeout") {
            lwrite("Connection timed out. Retrying...")
        } else {
            lwrite("An unexpected error occurred:")
            lwrite($_.Exception.Message)
            break
        }
    }
  }
  if ($Attempt -eq $MaxAttempts) {
    Write-Host "Reached maximum number of attempts. Continuing..."
  }
}

if (Test-Path -Path "C:\Tools\atomic-red-team-master.zip") {
  lwrite("Expanding atomic red team zip archive")
  Expand-Archive -Force -LiteralPath 'C:\Tools\atomic-red-team-master.zip' -DestinationPath 'C:\Tools\atomic-red-team-master'
} else {
  lwrite("Something went wrong - atomic red team zip not found")
}

# Install invoke-atomicredteam Module
lwrite("Installing Module invoke-atomicredteam")
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name invoke-atomicredteam,powershell-yaml -Scope AllUsers -Force
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics

lwrite("End of red.ps1")
