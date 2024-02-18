<powershell>
# Beginning of bootstrap script
# This script bootstraps the Windows system and runs
# extra scripts downloaded from the s3 bucket

$stagingdir = "C:\terraform"

if (-not (Test-Path -Path $stagingdir)) {
    New-Item -ItemType Directory -Path $stagingdir
    Write-Host "Directory created: $stagingdir"
} else {
    Write-Host "Directory already exists: $stagingdir"
}

# Set logfile and function for writing logfile
$logfile = "C:\Terraform\bootstrap_log.log"
Function lwrite {
    Param ([string]$logstring)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logstring = "$timestamp $logstring"
    Add-Content $logfile -value $logstring
}

lwrite("Starting bootstrap powershell script")

# add a local user and add them to Administrators
$admin_username = "${admin_username}"
$admin_password = "${admin_password}"
$op = Get-LocalUser | Where-Object {$_.Name -eq $admin_username}
if ( -not $op ) {
  $secure_string = ConvertTo-SecureString $admin_password -AsPlainText -Force
  New-LocalUser $admin_username -Password $secure_string
  Add-LocalGroupMember -Group "Administrators" -Member $admin_username
  lwrite("User created and added to the Administrators group: $admin_username")
} else {
  lwrite("User already exists: $admin_username")
}

# Set hostname
lwrite("Checking to rename computer to ${hostname}")

$current = $env:COMPUTERNAME

if ($current -ne "${hostname}") {
    Rename-Computer -NewName "${hostname}" -Force
    lwrite("Renaming computer and reboot")
    Restart-Computer -Force
} else {
    lwrite("Hostname already set correctly")
}

lwrite("Going to download from S3 bucket: ${s3_bucket}")
$scriptFilenames = "${script_files}".split(",")
foreach ($filename in $scriptFilenames) {
  lwrite("Processing script: $filename")
  $object_url = "https://" + "${s3_bucket}" + ".s3." + "${region}" + ".amazonaws.com/" + "$filename"
  lwrite("Downloading file: $object_url")
  # Download each file from s3 bucket and run them
  $outfile = "C:\terraform\" + "$filename"

  $MaxAttempts = 5
  $TimeoutSeconds = 30
  $Attempt = 0

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

  # Run the script
  lwrite("Running $outfile")
  & $outfile
}

</powershell>
<persist>true</persist>
