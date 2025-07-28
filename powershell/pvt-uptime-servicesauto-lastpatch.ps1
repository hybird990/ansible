# Prompt for vCenter credentials
$vCenterCred = Get-Credential -Message "Enter vCenter credentials"
Connect-VIServer -Server "192.168.1.13" -Credential $vCenterCred

# Prompt for domain (guest OS) credentials
$guestCred = Get-Credential -Message "Enter domain credentials for guest access"

# Read VM names from CSV
$vmList = Import-Csv -Path "C:\Temp\VMList.csv"
$results = @()
$reportPath = "C:\Temp\VMwareVMReport.txt"

foreach ($vm in $vmList) {
    try {
        $targetVM = Get-VM -Name $vm.Name

        # Use single-quoted here-string to simplify variable and character escaping
        $script = @'
$hostname = $env:COMPUTERNAME
$lastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

$updates = Get-HotFix | Where-Object {
    $_.InstalledOn -gt (Get-Date).AddDays(-30)
} | Select-Object HotFixID, InstalledOn

$services = Get-Service | Where-Object {
    $_.StartType -eq 'Automatic'
} | Select-Object Name, Status

$output = "Hostname: $hostname`nLast Reboot: $lastBoot`n`nRecent Updates:`n" + ($updates | Out-String) + "`nAutomatic Services:`n" + ($services | Out-String)
$output
'@

        # Execute the script inside the guest VM
        $vmOutput = Invoke-VMScript -VM $targetVM -ScriptText $script -GuestCredential $guestCred -ScriptType Powershell
        $results += "Results for $($vm.Name):`n$($vmOutput.ScriptOutput)`n`n"
    }
    catch {
        $results += "Error for $($vm.Name): $_`n`n"
    }
}

# Save report to file
$results | Out-File -FilePath $reportPath -Encoding UTF8

# Send report via email
Send-MailMessage -To "kad@vmware.local" -From "pvtchecks@vmware.local" `
    -Subject "PVT Checks Results" `
    -Body "See the attached report from today's scan." `
    -Attachments $reportPath `
    -SmtpServer "192.168.1.15"
