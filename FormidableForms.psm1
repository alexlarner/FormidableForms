#Requires -Version 7
#Requires -Module PSFramework

Set-StrictMode -Version Latest
$Script:ErrorActionPreference = 'Stop'

$ImportOrder = 'Functions'#, 'Variables', 'ArgumentCompleters'

foreach ($Folder in $ImportOrder) {
	Write-PSFMessage "Importing $Folder"
	Get-ChildItem $PSScriptRoot\$Folder\*.ps1 -Recurse | ForEach-Object {
		Write-PSFMessage "Importing $($_.Name)"
		. $_.FullName
	}
}

try {
	Connect-FFAPI
} catch {
	throw $_
}
Write-PSFMessage "BaseUrl is: $script:BaseURL"
Write-PSFMessage "FFAuthHeader Authorization is: $($FFAuthHeader.Authorization)"

Set-PSFFeature -Name PSFramework.InheritEnableException -Value $true -ModuleName FormidableForms

<#
	.SYNOPSIS
		Provides a PowerShell wrapper to the FormidableForms API
	.DESCRIPTION
		Provides a PowerShell wrapper to the FormidableForms API
	.NOTES
		Update History
		==============

		To Do
		=====
#>
