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
    It "should return a list of all files in working folder with no arguments provided" {
        
        $expected = @("test_file.edi", "wrong_extension.xml", "wrong_format.txt")

        Set-Location $PSScriptRoot\test_files
        $result = GetFileList
        $resultFilenames = $result | Split-Path -Leaf

        $resultFilenames | Should -HaveCount 3
        $resultFilenames | Should -Be $expected
    }
    It "should return a list with one file specified in argument" {
        $testPath = Join-Path $PSScriptRoot "test_files" "test_file.edi"
        $result = GetFileList -Paths $testPath
        
        $result | Split-Path -Leaf | Should -Be "test_file.edi"
    }
}