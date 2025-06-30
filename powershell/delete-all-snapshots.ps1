Connect-VIServer -Server 10.0.0.12 -Protocol https -User administrator@vsphere.local -Password VMware123!
Get-VM | Get-Snapshot | Remove-Snapshot -Confirm:$false
disconnect-VIServer -Server 10.0.0.12
