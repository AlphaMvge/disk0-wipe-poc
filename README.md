# disk0-wipe-poc
Proof-of-Concept: Unrecoverable Disk Wipe (Educational Only)

# ⚠️ Disk0 Unrecoverable Wipe – **PROOF OF CONCEPT ONLY**

> **NO REAL-WORLD, REAL-LIFE, OR OPERATIONAL USE**  
> **FOR ACADEMIC, FORENSIC RESEARCH, AND DEMONSTRATION PURPOSES ONLY**

---

## Ethical Scope (Binding)

| Condition                  | Status  |
|---------------------------|---------|
| Intended Use              | Educational / Theoretical |
| Real Systems              | **NEVER** |
| Production / Personal Data| **NEVER** |
| Live Environments         | **NEVER** |
| Deployment                | **NEVER** |

---

## PoC Simulation (Safe VHD Test)

Run in **elevated PowerShell**:

```powershell
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
$simLetter = (Get-Partition -DiskNumber $simDrive).DriveLetter + ": ":

Write-Host "[PoC] Simulating wipe on VHD Disk $simDrive ($simLetter)`n"

# === RUN MODIFIED SCRIPT HERE ===
# Replace `select disk 0` → `select disk $simDrive`
# See: wipe-disk0-unrecoverable.ps1

# Cleanup
Dismount-VHD $vhdPath
Remove-Item $vhdPath -Force
Write-Host "[PoC] Simulation complete. VHD deleted."

Method,Outcome
clean all,All sectors zeroed
3× entropy + cipher /w:,No recovery possible
Verification,Get-Content -Raw -Encoding Byte → all 0x00 or random

File,Purpose
wipe-disk0-unrecoverable.ps1,Core logic (PoC mode)
SIMULATION-TEST.ps1,Safe VHD demo


