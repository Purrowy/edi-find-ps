# log file settings
#$logFile = "$PSScriptRoot\log_$(Get-Date -Format "yyyy-MM-dd").txt" # save log in script's location
$logFile = "$(Get-Location)\log_$(Get-Date -Format "yyyy-MM-dd").txt" # save log in current dir
$logFile_is_empty = $true

# define keywords to search for
$keywords = @("UNB\+", "UNH\+", "BGM\+", "NAD\+BY", "NAD\+SE", "NAD\+IV", "NAD\+DP", "NAD\+CN", "UNZ\+");
$extensions = @(".txt", ".edi")

# basic logic for this script
function main {

    $files = GetFileList @args
    
    foreach ($file in $files) {
        if (ValidateFile) {
            CreateLogEntry
            $logFile_is_empty = $false
        }
    }

    if (-not ($logFile_is_empty)) {
        Write-Host "Script finished. Log created under '$(Get-Location)\log_$(Get-Date -Format "yyyy-MM-dd").txt'"
    }
    else {
        Write-Host "Script finished. No files to check were found."
    }
}

# Create list of files to check based on args given by user
function GetFileList {
    param (
        [string[]]$Paths
    )

    # If no arguments provided by user -> check all files from current directory
    if (-not $Paths) {
        $Paths = (Get-Location).Path
    }

    $list = @()

    foreach ($path in $Paths) {
        $resolvedPaths = Resolve-Path -Path $path -ErrorAction SilentlyContinue

        foreach ($resolvedPath in $resolvedPaths) {
            # if provided argument is a dir
            if (Test-Path -Path $resolvedPath -PathType Container) {
                $list += Get-ChildItem -Path $resolvedPath -File | Select-Object -ExpandProperty FullName
            }
            # if provided argument is a file
            elseif (Test-Path -Path $resolvedPath -PathType Leaf) {
                $list += $resolvedPath
            }
        }
    }

    return $list
}

function ValidateFile {

    if (-not (Test-Path $file)) {
        Write-Host "Error - $($file): file doesn't exist. File will not be included in final log."
        return $false
    }

    if (-not ($([System.IO.Path]::GetExtension($file)) -in $extensions)) {
        Write-Host "Error - $($file): incorrect file extension. File will not be included in final log."
        return $false
    }

    if (-not (Select-String $file -Pattern "UNB+" -Quiet)) {
        Write-Host "Error - $($file): wrong format. File will not be included in final log."
        return $false
    }

    return $true

}

function CreateLogEntry {

    $log_entry = @("File: $file", "***")

    $content = (Get-Content $file -Raw) -split "'"

    foreach ($keyword in $keywords) {
        $results = $content | Select-String -Pattern $keyword
        if ($results){
            # check for exceptions
            if ($keyword -eq "UNB\+") {
                $log_entry += "$results`n-----"
            }
            elseif ($keyword -eq "UNZ\+") {
                $log_entry += "-----`n$results`n***`n"
            } 
            else {
                $log_entry += "$results"
            }                
        }
    }
        $log_entry | Out-File -FilePath $logFile -Append
        return
}

main @args