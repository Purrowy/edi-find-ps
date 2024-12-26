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