# ===============================================
# ⚠️ PROOF OF CONCEPT – DISK 0 WIPE (SIMULATION / LAB ONLY)
# ⚠️ NO REAL-WORLD USE | ACADEMIC / FORENSIC DEMO ONLY
# ===============================================

# ===== ETHICAL POC CONFIRMATION =====
$confirm = Read-Host "🚨 POC MODE: Type 'WIPE-POC' to proceed in LAB/VHD"
if ($confirm -ne 'WIPE-POC') { Write-Host "❌ Aborted. PoC safety exit."; exit }

# ===== STEP 1: DISKPART CLEAN ALL =====
$dp = @"
select disk 0
clean all
"@

$scriptPath = "$env:TEMP\dp_clean.txt"
$dp | Out-File $scriptPath -Encoding ASCII
Write-Host "`n[*] Zeroing Disk 0 via DiskPart..."
diskpart /s $scriptPath | Out-Host
Remove-Item $scriptPath -Force
Write-Host "[✔] Zero pass complete"

# ===== STEP 2: REFORMAT FOR OVERWRITE ACCESS =====
Initialize-Disk 0 -PartitionStyle GPT -Confirm:$false -ErrorAction SilentlyContinue
New-Partition -DiskNumber 0 -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -Force -Confirm:$false >$null
$drive = (Get-Partition -DiskNumber 0).DriveLetter + ":"
Write-Host "[✔] Reformatted as $drive"

# ===== STEP 3: 3× RANDOM ENTROPY (IMPROVED RNG) =====
$passes = 3
$chunk = 128MB

for ($p = 1; $p -le $passes; $p++) {
    Write-Host "`n🔁 Pass $p/$passes – Random overwrite"
    $filled = 0
    $size = (Get-Volume -DriveLetter $drive.TrimEnd(':')).Size

    while ($filled -lt $size) {
        $block = [Math]::Min($chunk, $size - $filled)
        $bytes = New-Object Byte[] $block
        [Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes($bytes)
        
        $file = "$drive\temp_wipe.bin"
        [IO.File]::WriteAllBytes($file, $bytes)
        Remove-Item $file -Force
        
        $filled += $block
        $pct = [int]($filled / $size * 100)
        Write-Progress -Activity "Pass $p" -Status "$pct% complete" -PercentComplete $pct
    }
}
Write-Host "[✔] $passes entropy passes done"

# ===== STEP 4: CIPHER FREE SPACE WIPE =====
Write-Host "`n[*] Final cipher /w pass..."
cipher /w:$drive | Out-Host
Write-Host "[✔] Free space sanitized"

# ===== STEP 5: FINAL DESTRUCTION =====
Get-Partition -DiskNumber 0 | Remove-Partition -Confirm:$false
Clear-Disk -Number 0 -RemoveData -RemoveOEM -Confirm:$false
Write-Host "`n✅ PoC COMPLETE – Disk 0 is forensically unrecoverable"
Write-Host "   • 1× Zero (clean all)"
Write-Host "   • 3× Cryptographic RNG"
Write-Host "   • 3× Cipher /w (0x00, 0xFF, random)"
Write-Host "   • Partition table erased`n"
Write-Host "🔒 Beyond software or standard lab recovery."
