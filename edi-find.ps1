# log file settings
$logFile = "$PSScriptRoot\log_$(Get-Date -Format "yyyy-MM-dd").txt"

# define keywords to search for
$keywords = @("UNB+", "AB", "GH", "UNZ+");

# Create list of files to check based on args given by user
function get_file_list {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$args
    )

    $files = @()

    if ($args.Count -eq 0) {
        $files = Get-ChildItem -Path (Get-Location) -File | Select-Object -ExpandProperty FullName
    }

    else {
        $files = $args
    }
    
    return $files
}

$files = get_file_list @args

# loop through each file and check for keywords
foreach ($file in $files) {

    $log_entry = @()
    $log_entry += "File: $file`n***"

    # replace ' with newline
    $content = Get-Content $file -Raw
    $temp = $content -replace "'", [Environment]::NewLine
    $lines = $temp -split [Environment]::NewLine

    foreach ($keyword in $keywords) {
        $results = $lines | Select-String -Pattern $keyword
        if ($results) {

            # check for exceptions
            if ($keyword -eq "UNB+") {
                $log_entry += "$results`n-----"
            }
            elseif ($keyword -eq "UNZ+") {
                $log_entry += "-----`n$results`n"
            } 
            else {
                $log_entry += "$results"
            }
            
        }
    }

    $log_entry | Out-File -FilePath $logFile -Append

    }