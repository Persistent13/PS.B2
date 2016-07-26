# Remove the module and then import the module
$WorkspaceRoot = $(Get-Item $PSScriptRoot).Parent.FullName
Remove-Module 'PS.B2' -ErrorAction Ignore
Import-Module "$WorkspaceRoot\PS.B2\PS.B2.psd1" -Force

if($global:key -eq $null) {
    # Using json key.
    $settings = Get-Content $PSScriptRoot\testSettings.json | ConvertFrom-Json
    $global:key = $settings.ApiKey
}

InModuleScope PS.HealthChecks {
    Describe "PS.B2 class tests" {
        Context "Custom classes should instantiate" {
            It "Should create object" {
                $true | Should Not $true
            }
        }
    }
}