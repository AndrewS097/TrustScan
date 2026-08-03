# Privacy Exposure Checker
# Checks files for possible sensitive data exposure
# Saves text and CSV reports to the Desktop

param(
    [string]$ScanPath = [Environment]::GetFolderPath("Desktop"),
    [string]$Report = (Join-Path ([Environment]::GetFolderPath("Desktop")) "Privacy_Exposure_Report.txt"),
    [string]$CsvReport = (Join-Path ([Environment]::GetFolderPath("Desktop")) "Privacy_Exposure_Report.csv")
)

if (-not (Test-Path -Path $ScanPath -PathType Container)) {
    Write-Error "Scan path does not exist or is not a folder: $ScanPath"
    exit 1
}

try {
    "Privacy Exposure Checker Report" | Out-File $Report -ErrorAction Stop
}
catch {
    Write-Error "Could not create report: $Report"
    exit 1
}

"Generated: $(Get-Date)" | Out-File $Report -Append
"Computer: $env:COMPUTERNAME" | Out-File $Report -Append
"User: $env:USERNAME" | Out-File $Report -Append
"Scan Path: $ScanPath" | Out-File $Report -Append
"======================================" | Out-File $Report -Append
"" | Out-File $Report -Append

Write-Host "Running Privacy Exposure Checker..."
Write-Host "Scan path: $ScanPath"
Write-Host "Text report: $Report"
Write-Host "CSV report: $CsvReport"

$Patterns = @{
    "Email Address" = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
    "SSN Format" = "\b\d{3}-\d{2}-\d{4}\b"
    "Phone Number" = "\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"
    "Password Keyword" = "(?i)password\s*[:=]"
    "Token Keyword" = "(?i)token\s*[:=]"
    "API Key Keyword" = "(?i)api[_-]?key\s*[:=]"
    "AWS Access Key" = "\bAKIA[0-9A-Z]{16}\b"
    "GitHub Token" = "\bghp_[A-Za-z0-9]{36}\b"
}

$Extensions = ".txt", ".csv", ".log", ".json", ".xml", ".config", ".ini", ".ps1"

$Files = Get-ChildItem -Path $ScanPath -Recurse -File -ErrorAction SilentlyContinue |
Where-Object {
    $Extensions -contains $_.Extension -and
    $_.Length -lt 5MB -and
    $_.FullName -ne $Report -and
    $_.FullName -ne $CsvReport
}

$TotalFindings = 0
$CsvFindings = @()

"Files Scanned: $($Files.Count)" | Out-File $Report -Append
"" | Out-File $Report -Append

foreach ($File in $Files) {
    try {
        $Content = Get-Content $File.FullName -ErrorAction Stop
        $FileHadFinding = $false

        foreach ($Pattern in $Patterns.GetEnumerator()) {
            $PatternMatches = $Content | Select-String -Pattern $Pattern.Value -AllMatches
            $MatchCount = 0

            foreach ($PatternMatch in $PatternMatches) {
                $MatchCount += $PatternMatch.Matches.Count
            }

            if ($MatchCount -gt 0) {
                if ($FileHadFinding -eq $false) {
                    "File: $($File.FullName)" | Out-File $Report -Append
                    $FileHadFinding = $true
                }

                $LineNumbers = ($PatternMatches.LineNumber | Sort-Object -Unique) -join ", "

                "REVIEW: $($Pattern.Key) found $MatchCount time(s) on line(s): $LineNumbers" |
                    Out-File $Report -Append

                $CsvFindings += [PSCustomObject]@{
                    File = $File.FullName
                    FindingType = $Pattern.Key
                    Count = $MatchCount
                    LineNumbers = $LineNumbers
                }

                $TotalFindings++
            }
        }

        if ($FileHadFinding) {
            "" | Out-File $Report -Append
        }
    }
    catch {
        "Could not read file: $($File.FullName) - $($_.Exception.Message)" |
            Out-File $Report -Append
    }
}

"======================================" | Out-File $Report -Append
"Summary" | Out-File $Report -Append
"Total items to review: $TotalFindings" | Out-File $Report -Append

if ($TotalFindings -eq 0) {
    "PASS: No possible sensitive data patterns found." | Out-File $Report -Append
    '"File","FindingType","Count","LineNumbers"' | Out-File $CsvReport
}
else {
    "REVIEW: Possible sensitive data was found. Review the listed files." | Out-File $Report -Append
    $CsvFindings | Export-Csv -Path $CsvReport -NoTypeInformation
}

Write-Host "Scan complete."
Write-Host "Text report saved to: $Report"
Write-Host "CSV report saved to: $CsvReport"
