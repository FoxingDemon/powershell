<#
 .Synopsis
    Email backup sizes
 .DESCRIPTION
    Get Backup jobs´s sizes from a Veeam B&R server and send that information as an email.
 .EXAMPLE
    .\backupsize.ps1 -Email user@example.com
 .VERSION
    1.0 11.6.2016 
 .AUTHOR
    Vilma Hallikas
 
 #>
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$Email,
   [Parameter(Mandatory=$False)]
   [string]$Server
)

$Server = "10.255.0.10"
$results = ""

if ((Get-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue) -eq $null) {
    Add-PsSnapin -Name VeeamPSSnapIn
}

    Write-Host "Connecting to: $Server"
    Connect-VBRServer -Server $Server


function getBackupInfo()
{
    $backupJobs = Get-VBRBackup | sort Name
    $result = ""
    Write-Host "Getting data"

	foreach ($job in $backupJobs)
	{
        $restorePoints = $job.GetAllStorages() | sort CreationTime -descending
    
        $jobBackupSize = 0;
        $jobName = ($job | Select -ExpandProperty JobName)
        $result += "$jobName`t`t`t"
	

	    $jobBackupSize = [long]($restorepoints[0] | Select-Object -ExpandProperty stats | Select -ExpandProperty BackupSize)

        # convert to GB
        $jobBackupSize = [math]::Round(($jobBackupSize / 1024 / 1024 / 1024), 2);

        $result += "$jobBackupsize GB`n"
    }
    
    return $result

}

$results = getBackupinfo
Write-Host "Sending Email"
Send-MailMessage -To $Email -Subject "Varmistusmäärät" -Body $results -From tuki@tamico.fi -SmtpServer smtp.tamico.fi -Encoding UTF8
Disconnect-VBRServer
Write-Host "Disconnected"