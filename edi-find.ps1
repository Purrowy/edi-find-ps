# If user calls script with no arguments - use current dir
[CmdletBinding()]
param (
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Paths = @((Get-Location).Path)
)

# Log file settings
$logFile = "$PSScriptRoot\log_$(Get-Date -Format "yyyy-MM-dd").txt" # save log in script's location
#$logFile = "$(Get-Location)\log_$(Get-Date -Format "yyyy-MM-dd").txt" # save log in current dir

# Define keywords to search for
$keywords = @("UNB\+", "UNH\+", "BGM\+", "NAD\+BY", "NAD\+SE", "NAD\+IV", "NAD\+DP", "NAD\+CN", "UNZ\+");
$extensions = @(".txt", ".edi")

function main {
    
    $files = GetFileList -Paths $Paths
    
    foreach ($file in $files) {
        if (ValidateFile -file $file) {
            CreateLogEntry -file $file
            $createLog = $true
        }
    }

    if ($createLog) {
        Write-Host "Script finished. Log created under $logFile"
    }
    else {
        Write-Host "Script finished. No files to check were found."
    }
}

# Get list of files based on user input
function GetFileList {
    param (
        [string[]]$Paths
    )

    $list = @()

    foreach ($path in $Paths) {
        try {
            $resolvedPath = Resolve-Path -Path $path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
            if (-not $resolvedPath) {
                Write-Host "Path $path not found"
                continue
            }
            if (Test-Path -Path $resolvedPath -PathType Container) {
                $list += Get-ChildItem -Path $resolvedPath -File | Select-Object -ExpandProperty FullName
            }
            elseif (Test-Path -Path $resolvedPath -PathType Leaf) {
                $list += $resolvedPath
            }
        }

        catch {
            Write-Host "Error for: $path"
        }
    }

    return $list
}

# Check for extensions and if contains mandatory segment
function ValidateFile {
    param (
        [string]$file
    )

    if (-not ($([System.IO.Path]::GetExtension($file)) -in $extensions)) {
        Write-Host "Error - $($file): incorrect file extension. File will not be included in final log."
        return $false
    }

    if (-not (Select-String $file -Pattern "UNB\+" -Quiet)) {
        Write-Host "Error - $($file): wrong format. File will not be included in final log."
        return $false
    }

    return $true

}

function CreateLogEntry {
    param (
        [string]$file
    )

    $log_entry = @("File: $file", "***")

    # search line by line, EDIFACT segments are split by '
    (Get-Content $file -Raw) -split "'" | ForEach-Object {
        $line = $_.Trim()
        foreach ($keyword in $keywords) {
            if ($line -match $keyword) {
                if ($keyword -eq "UNH\+") {
                    $log_entry += "----------------------`n$line"
                    break
                }
                elseif ($keyword -eq "UNZ\+") {
                    $log_entry += "----------------------`n$line`n***`n"
                    break
                }
                else {                
                    $log_entry += "$line"
                    break
                }
            }
        }
    }

    $log_entry | Out-File -FilePath $logFile -Append
    return
}

main