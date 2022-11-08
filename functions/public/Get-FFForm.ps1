function Get-FFForm {
	[CmdletBinding(DefaultParameterSetName = 'All')]
	param (
		[Parameter(
			ParameterSetName = 'ID',
			ValueFromPipeline,
			ValueFromPipelineByPropertyName
		)]
		[int]$ID
	)
	process {
		if ($PSCmdlet.ParameterSetName -eq 'ID') {
			foreach ($FormID in $ID) {
				Invoke-FFAPI -URISuffix "/forms/$FormID"
			}
		} else {
			$Result = Invoke-FFAPI -URISuffix '/forms'
			$Result.PSObject.Properties.Name | ForEach-Object {
				$Result.$_
			}
		}
	}
}