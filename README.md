# TrustScan

TrustScan is a simple PowerShell tool that scans files for possible sensitive data exposure, such as emails, phone numbers, SSN patterns, passwords, tokens, and API key references.

## Overview

TrustScan checks a folder for possible sensitive information and creates a simple report. It does not change, delete, or edit any files. It only reports possible findings that may need review.

The tool looks for:

* Email addresses
* SSN-style patterns
* Phone numbers
* Password keywords
* Token keywords
* API key keywords

The report does not print the actual sensitive values. It only shows the type of finding, how many times it was found, and which file may need review.

## Theme

Human, Privacy, & Trust-Centered Security

## Why This Tool Is Useful

Sensitive information can accidentally be stored in text files, logs, scripts, configuration files, or exported data. This can create privacy and security risks if those files are shared, uploaded, or stored insecurely.

TrustScan helps users review files before sharing, submitting, or uploading them.

## Features

* Simple PowerShell script
* Beginner-friendly code
* Scans common text-based file types
* Creates a readable text report
* Does not expose the actual sensitive values
* Does not modify files
* Easy to run and test

## Requirements

* Windows 10 or Windows 11
* PowerShell
* Permission to read the folder being scanned

## How to Run

Download or clone this repository, then open PowerShell in the folder where the script is saved.

Run the tool with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\TrustScan.ps1
```

By default, the tool scans the Desktop.

To scan a specific folder, use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\TrustScan.ps1 -ScanPath "$env:USERPROFILE\Documents"
```

## Report Location

By default, the report is saved to:

```text
Desktop\TrustScan_Report.txt
```

## What the Script Checks

### 1. Email Addresses

Checks for possible email address patterns in supported files.

### 2. SSN Format

Checks for possible Social Security Number-style patterns, such as:

```text
123-45-6789
```

### 3. Phone Numbers

Checks for common phone number formats.

### 4. Password Keywords

Checks for password-related keywords, such as:

```text
password=
password:
```

### 5. Token Keywords

Checks for token-related keywords, such as:

```text
token=
token:
```

### 6. API Key Keywords

Checks for API key-related keywords, such as:

```text
api_key=
api-key:
apikey=
```

## Supported File Types

TrustScan scans common text-based files, including:

* `.txt`
* `.csv`
* `.log`
* `.json`
* `.xml`
* `.config`
* `.ini`
* `.ps1`

## Demo Test

Create a test folder and fake test file:

```powershell
mkdir $env:USERPROFILE\Desktop\TrustScanDemo
"email=test@example.com`npassword=demo123`ntoken=abc123`nssn=123-45-6789" | Out-File $env:USERPROFILE\Desktop\TrustScanDemo\test.txt
```

Run TrustScan against the test folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\TrustScan.ps1 -ScanPath "$env:USERPROFILE\Desktop\TrustScanDemo"
```

Open the report:

```powershell
notepad $env:USERPROFILE\Desktop\TrustScan_Report.txt
```

The report should show possible findings without displaying the actual sensitive values.

## Example Use Case

TrustScan can be used before uploading files to GitHub, submitting assignments, sharing logs, or sending folders to someone else. It gives users a simple way to check for possible privacy risks before files leave their system.

## Limitations

* This tool only checks text-based files.
* It does not scan binary files, images, or encrypted files.
* It may produce false positives.
* It does not confirm whether a value is truly sensitive.
* It does not remove or redact sensitive information.
* It should not replace a full data loss prevention tool.

## Disclaimer

This tool is for educational and authorized security testing purposes only. Only run it on files and folders you own or have permission to review.
