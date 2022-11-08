function Connect-FFAPI {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[PSCredential]$Credential,

		[System.IO.FileInfo]$CredentialPath = "$env:LOCALAPPDATA\FormidableForms\FormidableFormsCredentials.xml",

		[switch]$OverwriteSavedCredentials,

		[switch]$EnableException
	)
	process {
		if ($OverwriteSavedCredentials.IsPresent -or (-Not $CredentialPath.Exists)) {
			if (-Not $Credential) {
				$Credential = Get-Credential -Message 'Please provide your FormidableForms API URI as the username, and your API key as the password'
			}
			$ParentPath = Split-Path $CredentialPath
			if (-Not (Test-Path $ParentPath)) {
				Invoke-PSFProtectedCommand -Action 'Creating folder for FormidableForms API URI and key' -Target $ParentPath -ScriptBlock {
					New-Item -ItemType Directory -Path $ParentPath -ErrorAction Stop | Out-Null
				}
			}
			$Credential | Export-Clixml $CredentialPath.FullName
		} else {
			$Credential = Import-Clixml $CredentialPath
		}

		$script:BaseURL = $Credential.UserName
		#Yes this is not secure, as it passes the unencrypted API key into memory. Though I have not found any other way to convert a secure string to a Base64 string that the FormidableForms API will accept.
		$Base64Creds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$(ConvertFrom-SecureString $Credential.Password -AsPlainText):"))
		$script:FFAuthHeader = @{ 'Authorization' = "Basic $Base64Creds" }
	}
}