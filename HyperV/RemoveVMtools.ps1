# 1. Force remove from 'Apps & Features' list
$uninstPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($path in $uninstPaths) {
    Get-ChildItem -Path $path | Get-ItemProperty | Where-Object { $_.DisplayName -like "*VMware Tools*" } | ForEach-Object {
        Write-Host "Removing entry from Apps & Features: $($_.DisplayName)" -ForegroundColor Cyan
        Remove-Item -Path $_.PSPath -Recurse -Force
    }
}

# 2. Cleanup Installer/Product registration keys
$installerPaths = @(
    "HKLM:\SOFTWARE\Classes\Installer\Products",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
)

foreach ($path in $installerPaths) {
    Get-ChildItem -Path $path | Get-ItemProperty | Where-Object { $_.ProductName -like "*VMware Tools*" } | ForEach-Object {
        Write-Host "Cleaning up MSI registration: $($_.ProductName)" -ForegroundColor Cyan
        Remove-Item -Path $_.PSPath -Recurse -Force
    }
}

# 3. Final Folder Cleanup
$folders = @("C:\Program Files\VMware\VMware Tools", "C:\ProgramData\VMware")
foreach ($f in $folders) {
    if (Test-Path $f) { Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host "Cleanup finished. Please REBOOT to see changes in Apps & Features." -ForegroundColor Green
