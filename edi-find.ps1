# log file settings
#$logFile = "$PSScriptRoot\log_$(Get-Date -Format "yyyy-MM-dd").txt" # save log in script's location
$logFile = "$(Get-Location)\log_$(Get-Date -Format "yyyy-MM-dd").txt" # save log in current dir

# define keywords to search for
$keywords = @("UNB+", "AB", "GH", "UNZ+");
$extensions = @(".txt", ".edi")

# basic logic for this script
function main {

    $files = GetFileList @args
    
    foreach ($file in $files) {
        if (ValidateFile $file) {
            CreateLogEntry $file
        }
    }
}

# Create list of files to check based on args given by user
function GetFileList {

    $list = @()

    if ($args.Count -eq 0) {
        $list = Get-ChildItem -Path (Get-Location) -File | Select-Object -ExpandProperty FullName
    }
    else {
        $list = $args
    }  

    return $list
}

function ValidateFile {

    if (-not (Test-Path $file)) {
        Write-Host "$($file): file doesn't exist"
        return $false
    }

    if (-not ($([System.IO.Path]::GetExtension($file)) -in $extensions)) {
        Write-Host "$($file): incorrect file extension"
        return $false
    }

    if (-not (Select-String $file -Pattern "UNB+" -Quiet)) {
        Write-Host "$($file): wrong format"
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
            if ($keyword -eq "UNB+") {
                $log_entry += "$results`n-----"
            }
            elseif ($keyword -eq "UNZ+") {
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