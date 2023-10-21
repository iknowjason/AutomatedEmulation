
# Set logfile and function for writing logfile
$logfile = "C:\Terraform\sysmon_log.log"
Function lwrite {
    Param ([string]$logstring)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logstring = "$timestamp $logstring"
    Add-Content $logfile -value $logstring
}
lwrite("Starting sysmon.ps1")

# Set DNS resolver to google
lwrite("Setting DNS resolver to public DNS")
$myindex = Get-Netadapter -Name "Ethernet" | Select-Object -ExpandProperty IfIndex
  Set-DNSClientServerAddress -InterfaceIndex $myindex -ServerAddresses "8.8.8.8"

# Download Sysmon config xml
$object_url = "https://" + "${s3_bucket}" + ".s3." + "${region}" + ".amazonaws.com/" + "${sysmon_config}"
$outfile = "C:\terraform\" + "${sysmon_config}"
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0
lwrite("Going to download from S3 bucket: ${s3_bucket}")
lwrite("object url: $object_url")

if (Test-Path -Path "C:\Terraform\${sysmon_config}") {
  lwrite("sysmon config exists")
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
# Finished Download of Sysmon config xml


# Download Sysmon zip 
$object_url = "https://" + "${s3_bucket}" + ".s3." + "${region}" + ".amazonaws.com/" + "${sysmon_zip}"
$outfile = "C:\terraform\" + "${sysmon_zip}"
$MaxAttempts = 5
$TimeoutSeconds = 30
$Attempt = 0
lwrite("Going to download from S3 bucket: ${s3_bucket}")
lwrite("object url: $object_url")

if (Test-Path -Path "C:\Terraform\${sysmon_zip}") {
  lwrite("sysmon zip exists")
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
# Finished Download of Sysmon zip

# Expand the Sysmon zip archive
if (Test-Path -Path "C:\Terraform\${sysmon_zip}") {
  lwrite("Expand the sysmon zip file")
  Expand-Archive -Force -LiteralPath 'C:\terraform\${sysmon_zip}' -DestinationPath 'C:\terraform\Sysmon' 
} else {
  lwrite("Something wrong - sysmon zip file doesn't exist")
}

# Copy the Sysmon configuration for SwiftOnSecurity to destination Sysmon folder
lwrite("Copy the Sysmon configuration for SwiftOnSecurity to destination Sysmon folder")
Copy-Item "C:\terraform\sysmonconfig-export.xml" -Destination "C:\terraform\Sysmon"

# Install Sysmon
lwrite("Install Sysmon")
C:\terraform\Sysmon\sysmon.exe -accepteula -i C:\terraform\Sysmon\sysmonconfig-export.xml 

lwrite("End of sysmon.ps1")
