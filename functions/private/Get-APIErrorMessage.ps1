function Get-APIErrorMessage {
	[CmdletBinding()]
	param (
		[Parameter(
			Mandatory,
			ValueFromPipeline
		)]
		[string[]]$ErrorJSON
	)
	process {
		$APIError = $ErrorJSON | ConvertFrom-Json
		Write-PSFMessage -Level SomewhatVerbose -Message "Parsed object from:`r`n$ErrorJSON" -Target $APIError

		if ($APIError.PSObject.Properties.Name -contains 'Message') {
			Write-PSFMessage -Level SomewhatVerbose -Message 'The API error directly contains a message property'
			Write-Output $APIError.Message
		} elseif ($APIError.PSObject.Properties.Name -contains 'Errors') {
			if ($APIError.Errors[0].PSObject.Properties.Name -contains 'Message') {
				#If they're all missing_field errors, return one missing field message with the field names appended. This happens a lot with items with mandatory custom fields, i.e new service requests (New-FSServiceRequest)
				if (($APIError.Errors.code | Select-Object -Unique) -eq 'missing_field') {
					Write-PSFMessage -Level SomewhatVerbose -Message 'All errors are missing field errors'
					Write-Output "$($APIError.Errors[0].Message): $($APIError.Errors.Field -join ', ')"
				} else {
					$Messages = foreach ($ErrorObject in $APIError.Errors) {
						$Message = $ErrorObject.Message
						Write-PSFMessage -Level SomewhatVerbose -Message "Parsing error metadata for this error message" -Target $Message
						if ($ErrorObject.PSObject.Properties.Name -contains 'field') {
							$Message = "$($ErrorObject.Field.ToUpper()) Field: $Message"
						}
						if ($ErrorObject.PSObject.Properties.Name -contains 'code') {
							$Message = "$Message (ERROR CODE: $($ErrorObject.code))"
						}
						$Message
						#Write-PSFMessage -Level SomewhatVerbose -Message "Reconstructed error message is $Message"
					}
					Write-Output ($Messages -join ', ')
				}
			} else {
				Write-PSFMessage -Level Warning -Message 'API error message did not contain a Message property under its Errors property'
			}
		} else {
			Write-PSFMessage -Level Warning -Message 'API error message did not contain a Message or Errors property'
		}
	}
}