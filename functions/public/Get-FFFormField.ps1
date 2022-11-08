function Get-FFFormField {
	[CmdletBinding(DefaultParameterSetName = 'All')]
	param (
		[Parameter(Mandatory)]
		[int]$FormID,

		[Parameter(
			ParameterSetName = 'ID',
			ValueFromPipeline,
			ValueFromPipelineByPropertyName
		)]
		[Alias('FieldID')]
		[int[]]$ID,

		[switch]$KeyNameTranslationOnly
	)
	process {
		$Fields = if ($PSCmdlet.ParameterSetName -eq 'ID') {
			$ID | ForEach-Object {
				Write-PSFMessage "Getting field $_ for form $FormID"
				Invoke-FFAPI -URISuffix "/forms/$FormID/fields/$_"
			}
		} else {
			Write-PSFMessage "Getting fields for form $FormID"
			$Result = Invoke-FFAPI -URISuffix "/forms/$FormID/fields"
			$Result.PSObject.Properties.Name | ForEach-Object {
				$Result.$_
			}
		}

		if ($KeyNameTranslationOnly.IsPresent) {
			$FieldTranslations = @{}
			$Fields | ForEach-Object {
				$FieldTranslations.($_.Field_Key) = $_.Name
			}
			Write-Output $FieldTranslations
		} else {
			Write-Output $Fields
		}
	}
}