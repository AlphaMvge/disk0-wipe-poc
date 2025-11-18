# SIMULATION-TEST.ps1
# Safe PoC: Wipe a virtual disk (VHD) – NO PHYSICAL IMPACT

# SIMULATED DISK 0 (VHD) – NO PHYSICAL IMPACT
$vhdPath = "$env:TEMP\SIM-DISK0.vhd"
$sizeGB = 1  # 1GB test disk

# Create virtual disk
New-VHD -Path $vhdPath -SizeBytes ($sizeGB * 1GB) -Fixed | 
  Mount-VHD -PassThru | 
  Initialize-Disk -PartitionStyle GPT -PassThru | 
  New-Partition -AssignDriveLetter -UseMaximumSize | 
  Format-Volume -FileSystem NTFS -Confirm:$false

$simDrive = (Get-Disk | Where-Object {$_.Path -like "*VHD*"}).Number
$simLetter = (Get-Partition -DiskNumber $simDrive).DriveLetter + ":"

Write-Host "[PoC] Simulating wipe on VHD Disk $simDrive ($simLetter)`n"

# === RUN MODIFIED SCRIPT HERE ===
# Replace `select disk 0` → `select disk $simDrive` in wipe-disk0-unrecoverable.ps1
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\wipe-disk0-unrecoverable.ps1`" $simDrive" -Verb RunAs -Wait

# Cleanup
Dismount-VHD $vhdPath
Remove-Item $vhdPath -Force
Write-Host "[PoC] Simulation complete. VHD deleted."
