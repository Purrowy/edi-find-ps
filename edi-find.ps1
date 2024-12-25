# Create list of files to check based on args given by user
param([Parameter(ValueFromRemainingArguments=$true)]$args)
$files = @()

if ($args.Count -eq 0) {
    $files = Get-ChildItem -Path $PSScriptRoot -File | Select-Object -ExpandProperty FullName
}

else {
    $files = $args
}

# log file settings
$date = Get-Date -Format "yyyy-MM-dd"
$logFile = "$PSScriptRoot\log_$date.txt"

# define keywords to search for
$keywords = @("AA", "GH");
$loop_count = 0

# loop through each file and check for keywords
foreach ($file in $files) {

    # replace ' with newline
    $temp0 = Get-Content $file -Raw
    $temp = $temp0 -replace "'", [Environment]::NewLine
    $loop_count
    $loop_count ++
    Write-Output Get-Content $temp
    $file

    foreach ($keyword in $keywords) {
        $results = Get-Content $temp | Select-String -Pattern $keyword
        Write-Output $results
    }

    }




<#     "File: $($file)" | Out-File -FilePath $logFile -Append
    foreach ($keyword in $keywords) {
        $results = Get-Content $file | Select-String -Pattern $keyword
        if ($results) {
            $results | Out-File -FilePath $logFile -Append
        }
    }
    "----------" | Out-File -FilePath $logFile -Append #>