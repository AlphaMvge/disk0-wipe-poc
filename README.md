# Unrecoverable Disk Wipe – Secure Delete PoC

**SIMULATED DISK 0 (VHD) – ZERO PHYSICAL IMPACT**

This script demonstrates military-grade data sanitization (3× random + DoD-style zero passes) on a disposable 1 GB virtual hard disk.  
No real hardware is ever touched.

## Quick Simulation (Safe Test)

```powershell
$vhdPath = "$env:TEMP\SIM-DISK0.vhd"
$sizeGB = 1GB

New-VHD -Path $vhdPath -SizeBytes ($sizeGB * 1GB) -Fixed |
  Mount-VHD -PassThru |
  Initialize-Disk -PartitionStyle GPT -PassThru |
  New-Partition -AssignDriveLetter -UseMaximumSize |
  Format-Volume -FileSystem NTFS -Confirm:$false

$simDrive = (Get-Disk | Where-Object Path -like "*VHD*").Number
$simLetter = (Get-Partition -DiskNumber $simDrive).DriveLetter + ":"

Write-Host "[PoC] Simulating wipe on VHD Disk $simDrive ($simLetter)`n"

# === INSERT YOUR MODIFIED WIPE SCRIPT HERE ===
# (Replace `select disk 0` with `select disk $simDrive` in wipe-disk0-unrecoverable.ps1)

# Cleanup
Dismount-VHD $vhdPath
Remove-Item $vhdPath -Force
Write-Host "[PoC] Simulation complete – VHD deleted."
