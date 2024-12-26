BeforeAll {
    . $("$PSScriptRoot\edi-find.ps1")
}

Describe "ValidateFile" {
    It "should return false - file does not exist" {
        $file = "$PSSCriptRoot\test_files\non_existent.file"
        ValidateFile $file | Should -Be $false
    }
    It "should return false - file has incorrect extension" {
        $file = "$PSScriptRoot\test_files\wrong_extension.xml"
        ValidateFile $file | Should -Be $false
    }
    It "should return false - no edi segments inside the file" {
        $file = "$PSScriptRoot\test_files\wrong_format.txt"
        ValidateFile($file) | Should -Be $false
    }
    It "should return true - all previous checks should pass" {
        $file = "$PSScriptRoot\test_files\test_file.edi" 
        ValidateFile $file | Should -Be $true
    }
}

Describe "GetFileList" {
    It "should return a list of all files in working folder if no arguments were provided" {        
        $expected = @("test.log", "test_file.edi", "wrong_extension.xml", "wrong_format.txt")

        Set-Location $PSScriptRoot\test_files
        $result = GetFileList
        $resultFilenames = $result | Split-Path -Leaf

        $resultFilenames | Should -HaveCount 4
        $resultFilenames | Should -Be $expected
    }
    It "should return a list of all files in target folder if user provided folder path" {
        $expected = @("test.log", "test_file.edi", "wrong_extension.xml", "wrong_format.txt")
        $testPath = Join-Path $PSScriptRoot "test_files\"
        $result = GetFileList -Paths $testPath
        $resultFilenames = $result | Split-Path -Leaf

        $resultFilenames | Should -HaveCount 4
        $resultFilenames | Should -Be $expected
    }
    It "should return a list with one file specified in argument" {
        $testPath = Join-Path $PSScriptRoot "test_files\test_file.edi"
        $result = GetFileList -Paths $testPath
        
        $result | Split-Path -Leaf | Should -Be "test_file.edi"
        $result | Should -HaveCount 1
    }
}

Describe "CreateLogEntry" {
    It "should match expected if provided with file in edi format" {
        $testFile = Join-Path $PSScriptRoot "test_files\test_file.edi"
        $expected = Get-Content $PSScriptRoot\test_files\test.log
        $expected[0] = "File: $PSScriptRoot\test_files\test_file.edi"

        
        $logFile = "$PSScriptRoot\test_files\log_$(Get-Date -Format "yyyy-MM-dd").txt"
        $result = CreateLogEntry $testFile -ReturnLogFile
        $result | Should -Be $expected
        
        Remove-Item -Path "$PSScriptRoot\test_files\log_$(Get-Date -Format "yyyy-MM-dd").txt"        
    }
}