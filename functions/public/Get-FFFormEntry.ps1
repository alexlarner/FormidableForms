function Get-FFFormEntry {
	[CmdletBinding(DefaultParameterSetName = 'All')]
	param (
		[Parameter(
			Mandatory,
			ValueFromPipelineByPropertyName
		)]
		[int]$FormID,

		[Parameter(
			ParameterSetName = 'ID',
			ValueFromPipeline,
			ValueFromPipelineByPropertyName
		)]
		[Alias('EntryID')]
		[int[]]$ID,

		[switch]$PreserveFieldKeys,

		[switch]$IncludeMetadata
	)
	process {
		$RawEntries = if ($PSCmdlet.ParameterSetName -eq 'ID') {
			$ID | ForEach-Object {
				Write-PSFMessage "Getting entry $_ from form $FormID"
				Invoke-FFAPI -URISuffix "/entries/$_"
			}
		} else {
			Write-PSFMessage "Getting entries from form $FormID"
			$Result = Invoke-FFAPI -URISuffix "/forms/$FormID/entries"
			if ($Result) {
				$Result.PSObject.Properties.Name | ForEach-Object {
					$Result.$_
				}
			}
		}

		if (-Not $PreserveFieldKeys.IsPresent) {
			$FieldTranslation = Get-FFFormField -FormID $FormID -KeyNameTranslationOnly
			foreach ($Entry in $RawEntries) {
				$TranslatedEntry = @{}
				foreach ($FieldKey in $Entry.meta.PSObject.Properties.Name) {
					Write-PSFMessage -Level Debug -Message "Translating $FieldKey to its field name"
					$FieldName = if ($FieldKey -match '\-value') {
						$PartialFieldName = $FieldKey.split('-value')[0]
						Write-PSFMessage -Level Debug -Message "$FieldKey contains '-value', the partial field name is $PartialFieldName"
						"$($FieldTranslation.$PartialFieldName)-value"
					} else {
						$FieldTranslation.$FieldKey
					}
					Write-PSFMessage -Level Debug -Message "$FieldKey = $FieldName"
					$TranslatedEntry.$FieldName = $Entry.meta.$FieldKey
				}
				$Entry.meta = [PSCustomObject]$TranslatedEntry
			}
		}

		if ($IncludeMetadata.IsPresent) {
			Write-Output $RawEntries
		} else {
			if ($RawEntries) { Write-Output $RawEntries.Meta }
		}
	}
}

