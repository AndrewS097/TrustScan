# Privacy Exposure Checker
# Checks files for possible sensitive data exposure
# Saves a report to the Desktop

param(
    [string]$ScanPath = "$env:USERPROFILE\Desktop",
    [string]$Report = "$env:USERPROFILE\Desktop\Privacy_Exposure_Report.txt"
)

"Privacy Exposure Checker Report" | Out-File $Report
"Generated: $(Get-Date)" | Out-File $Report -Append
"Computer: $env:COMPUTERNAME" | Out-File $Report -Append
"User: $env:USERNAME" | Out-File $Report -Append
"Scan Path: $ScanPath" | Out-File $Report -Append
"======================================" | Out-File $Report -Append
"" | Out-File $Report -Append

Write-Host "Running Privacy Exposure Checker..."

$Patterns = @{
    "Email Address" = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
    "SSN Format" = "\b\d{3}-\d{2}-\d{4}\b"
    "Phone Number" = "\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"
    "Password Keyword" = "(?i)password\s*[:=]"
    "Token Keyword" = "(?i)token\s*[:=]"
    "API Key Keyword" = "(?i)api[_-]?key\s*[:=]"
}

$Extensions = ".txt", ".csv", ".log", ".json", ".xml", ".config", ".ini", ".ps1"

$Files = Get-ChildItem -Path $ScanPath -Recurse -File -ErrorAction SilentlyContinue |
Where-Object {
    $Extensions -contains $_.Extension -and $_.Length -lt 5MB
}

$TotalFindings = 0

"Files Scanned: $($Files.Count)" | Out-File $Report -Append
"" | Out-File $Report -Append

foreach ($File in $Files) {
    try {
        $Content = Get-Content $File.FullName -Raw -ErrorAction Stop
        $FileHadFinding = $false

        foreach ($Pattern in $Patterns.GetEnumerator()) {
            $Matches = [regex]::Matches($Content, $Pattern.Value)

            if ($Matches.Count -gt 0) {
                if ($FileHadFinding -eq $false) {
                    "File: $($File.FullName)" | Out-File $Report -Append
                    $FileHadFinding = $true
                }

                "REVIEW: $($Pattern.Key) found $($Matches.Count) time(s)" | Out-File $Report -Append
                $TotalFindings++
            }
        }

        if ($FileHadFinding) {
            "" | Out-File $Report -Append
        }
    }
    catch {
        "Could not read file: $($File.FullName)" | Out-File $Report -Append
    }
}

"======================================" | Out-File $Report -Append
"Summary" | Out-File $Report -Append
"Total items to review: $TotalFindings" | Out-File $Report -Append

if ($TotalFindings -eq 0) {
    "PASS: No possible sensitive data patterns found." | Out-File $Report -Append
}
else {
    "REVIEW: Possible sensitive data was found. Review the listed files." | Out-File $Report -Append
}

Write-Host "Scan complete."
Write-Host "Report saved to: $Report"
