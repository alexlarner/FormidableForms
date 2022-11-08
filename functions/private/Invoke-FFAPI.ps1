Function Invoke-FFAPI {
	<#
		.SYNOPSIS
			Sends an HTTP or HTTPS request to a RESTful web service.

		.DESCRIPTION
			The `` cmdlet sends HTTP and HTTPS requests to Representational State Transfer (REST) web services that return richly structured data.

			PowerShell formats the response based to the data type. For an RSS or ATOM feed, PowerShell returns the Item or Entry XML nodes. For JavaScript Object Notation (JSON) or XML, PowerShell converts, or deserializes, the content into `[PSCustomObject]` objects.

			> [!NOTE] > When the REST endpoint returns multiple objects, the objects are received as an array. If you pipe > the output from `` to another command, it is sent as a single `[Object[]]` > object. The contents of that array are not enumerated for the next command on the pipeline.

			This cmdlet is introduced in Windows PowerShell 3.0.

			Beginning in PowerShell 7.0, `` supports proxy configuration defined by environment variables. See the Notes (#notes)section of this article.

		.PARAMETER AllowUnencryptedAuthentication
			Allows sending of credentials and secrets over unencrypted connections. By default, supplying Credential or any Authentication option with a Uri that does not begin with `https://` will result in an error and the request will abort to prevent unintentionally communicating secrets in plain text over unencrypted connections. To override this behavior at your own risk, supply the AllowUnencryptedAuthentication parameter.

			> [!WARNING] > Using this parameter is not secure and is not recommended. It is provided only for compatibility > with legacy systems that cannot provide encrypted connections. Use at your own risk.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER Authentication
			Specifies the explicit authentication type to use for the request. The default is None . Authentication can't be used with UseDefaultCredentials .

			Available Authentication Options:

			- `None`: This is the default option when Authentication is not supplied. No explicit   authentication will be used. - `Basic`: Requires Credential . The credentials will be used to send an RFC 7617 Basic   Authentication `Authorization: Basic` header in the format of `base64(user:password)`. - `Bearer`: Requires Token . Will send and RFC 6750 `Authorization: Bearer` header with the   supplied token. This is an alias for OAuth - `OAuth`: Requires Token . Will send an RFC 6750 `Authorization: Bearer` header with the   supplied token. This is an alias for Bearer Supplying Authentication will override any `Authorization` headers supplied to Headers or included in WebSession .

			This feature was added in PowerShell 6.0.0.

		.PARAMETER Body
			Specifies the body of the request. The body is the content of the request that follows the headers. You can also pipe a body value to ``.

			The Body parameter can be used to specify a list of query parameters or specify the content of the response.

			When the input is a GET request, and the body is an `IDictionary` (typically, a hash table), the body is added to the Uniform Resource Identifier (URI) as query parameters. For other request types (such as POST), the body is set as the value of the request body in the standard name=value format.

			When the body is a form, or it's the output of another `Invoke-WebRequest` call, PowerShell sets the request content to the form fields.

			The Body parameter may also accept a System.Net.Http.MultipartFormDataContent object. This will facilitate `multipart/form-data` requests. When a MultipartFormDataContent object is supplied for Body , any content related headers supplied to the ContentType , Headers , or WebSession parameters will be overridden by the content headers of the `MultipartFormDataContent` object. This feature was added in PowerShell 6.0.0.

		.PARAMETER Certificate
			Specifies the client certificate that is used for a secure web request. Enter a variable that contains a certificate or a command or expression that gets the certificate.

			To find a certificate, use `Get-PfxCertificate` or use the `Get-ChildItem` cmdlet in the Certificate (`Cert:`) drive. If the certificate isn't valid or doesn't have sufficient authority, the command fails.

		.PARAMETER CertificateThumbprint
			Specifies the digital public key certificate (X509) of a user account that has permission to send the request. Enter the certificate thumbprint of the certificate.

			Certificates are used in client certificate-based authentication. They can be mapped only to local user accounts; they do not work with domain accounts.

			To get a certificate thumbprint, use the `Get-Item` or `Get-ChildItem` command in the PowerShell `Cert:` drive.

			> [!NOTE] > This feature is currently only supported on Windows OS platforms.

		.PARAMETER ContentType
			Specifies the content type of the web request.

			If this parameter is omitted and the request method is POST, `` sets the content type to `application/x-www-form-urlencoded`. Otherwise, the content type isn't specified in the call. ContentType will be overridden when a `MultipartFormDataContent` object is supplied for Body .

		.PARAMETER Credential
			Specifies a user account that has permission to send the request. The default is the current user.

			Type a user name, such as User01 or Domain01\User01 , or enter a PSCredential object generated by the `Get-Credential` cmdlet. Credential can be used alone or in conjunction with certain Authentication parameter options. When used alone, it will only supply credentials to the remote server if the remote server sends an authentication challenge request. When used with Authentication options, the credentials will be explicitly sent.

			Credentials are stored in a PSCredential (/dotnet/api/system.management.automation.pscredential)object and the password is stored as a SecureString (/dotnet/api/system.security.securestring).

			> [!NOTE] > For more information about SecureString data protection, see > How secure is SecureString? (/dotnet/api/system.security.securestring#how-secure-is-securestring).

		.PARAMETER DisableKeepAlive
			Indicates that the cmdlet sets the KeepAlive value in the HTTP header to False. By default, KeepAlive is True. KeepAlive establishes a persistent connection to the server to facilitate subsequent requests.

		.PARAMETER FollowRelLink
			Indicates the cmdlet should follow relation links.

			Some REST APIs support pagination via Relation Links per RFC5988 (https://tools.ietf.org/html/rfc5988#page-6). Instead of parsing the header to get the URL for the next page, you can have the cmdlet do this for you. To set how many times to follow relation links, use the MaximumFollowRelLink parameter.

			When using this switch, the cmdlet returns a collection of pages of results. Each page of results may contain multiple result items.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER Form
			Converts a dictionary to a `multipart/form-data` submission. Form may not be used with Body . If ContentType will be ignored.

			The keys of the dictionary will be used as the form field names. By default, form values will be converted to string values.

			If the value is a System.IO.FileInfo object, then the binary file contents will be submitted. The name of the file will be submitted as the `filename`. The MIME will be set as `application/octet-stream`. `Get-Item` can be used to simplify supplying the System.IO.FileInfo object.

			$Form = @{

			resume = Get-Item 'c:\Users\jdoe\Documents\John Doe.pdf'

			}

			If the value is a collection type, such as an Array or List, the for field will be submitted multiple times. The values of the list will be treated as strings by default. If the value is a System.IO.FileInfo object, then the binary file contents will be submitted. Nested collections aren't supported.

			$Form = @{

			tags     = 'Vacation', 'Italy', '2017'

			pictures = Get-ChildItem 'c:\Users\jdoe\Pictures\2017-Italy\'
			}

			In the above example, the `tags` field will be supplied three times in the form, once for each of `Vacation`, `Italy`, and `2017`. The `pictures` field will also be submitted once for each file in the `2017-Italy` folder. The binary contents of the files in that folder will be submitted as the values.

			This feature was added in PowerShell 6.1.0.


		.PARAMETER Headers
			Specifies the headers of the web request. Enter a hash table or dictionary.

			To set UserAgent headers, use the UserAgent parameter. You cannot use this parameter to specify `User-Agent` or cookie headers.

			Content related headers, such as `Content-Type` will be overridden when a `MultipartFormDataContent` object is supplied for Body .

		.PARAMETER InFile
			Gets the content of the web request from a file.

			Enter a path and file name. If you omit the path, the default is the current location.

		.PARAMETER MaximumFollowRelLink
			Specifies how many times to follow relation links if FollowRelLink is used. A smaller value may be needed if the REST api throttles due to too many requests. The default value is `[Int32]::MaxValue`. A value of 0 (zero) prevents following relation links.

		.PARAMETER MaximumRedirection
			Specifies how many times PowerShell redirects a connection to an alternate Uniform Resource Identifier (URI) before the connection fails. The default value is 5. A value of 0 (zero) prevents all redirection.

		.PARAMETER MaximumRetryCount
			Specifies how many times PowerShell retries a connection when a failure code between 400 and 599, inclusive or 304 is received. Also see RetryIntervalSec parameter for specifying number of retries.

		.PARAMETER Method
			Specifies the method used for the web request. The acceptable values for this parameter are:

			- `Default`
			- `Delete`
			- `Get`
			- `Head`
			- `Merge`
			- `Options`
			- `Patch`
			- `Post`
			- `Put`
			- `Trace`

			The CustomMethod parameter can be used for Request Methods not listed above.


		.PARAMETER NoProxy
			Indicates that the cmdlet will not use a proxy to reach the destination.

			When you need to bypass the proxy configured in Internet Explorer, or a proxy specified in the environment, use this switch.

			This parameter was introduced in PowerShell 6.0.

		.PARAMETER OutFile
			Saves the response body in the specified output file. Enter a path and file name. If you omit the path, the default is the current location. The name is treated as a literal path. Names that contain brackets (`[]`) must be enclosed in single quotes (`'`).

			By default, `` returns the results to the pipeline.

		.PARAMETER PassThru
			This parameter is valid only when the OutFile parameter is also used in the command. The intent is to have the results written to the file and to the pipeline.

			> [!NOTE] > When you use the PassThru parameter, the output is written to the pipeline but the file is not > created. For more information, see > PowerShell Issue #15409 (https://github.com/PowerShell/PowerShell/issues/15409).

		.PARAMETER PreserveAuthorizationOnRedirect
			Indicates the cmdlet should preserve the `Authorization` header, when present, across redirections.

			By default, the cmdlet strips the `Authorization` header before redirecting. Specifying this parameter disables this logic for cases where the header needs to be sent to the redirection location.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER Proxy
			Uses a proxy server for the request, rather than connecting directly to the internet resource. Enter the Uniform Resource Identifier (URI) of a network proxy server.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER ProxyCredential
			Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter. The default is the current user.

			Type a user name, such as User01 or Domain01\User01 , User@Domain.Com , or enter a `PSCredential` object, such as one generated by the `Get-Credential` cmdlet.

			This parameter is valid only when the Proxy parameter is also used in the command. You can't use the ProxyCredential and ProxyUseDefaultCredentials parameters in the same command.

		.PARAMETER ProxyUseDefaultCredentials
			Indicates that the cmdlet uses the credentials of the current user to access the proxy server that is specified by the Proxy parameter.

			This parameter is valid only when the Proxy parameter is also used in the command. You can't use the ProxyCredential and ProxyUseDefaultCredentials parameters in the same command.

		.PARAMETER ResponseHeadersVariable
			Creates a Response Headers Dictionary and saves it in the value of the specified variable. The keys of the dictionary will contain the field names of the Response Header returned by the web server and the values will be the respective field values.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER Resume
			Performs a best effort attempt to resume downloading a partial file. The Resume parameter requires the OutFile parameter. Resume only operates on the size of the local file and remote file and performs no other validation that the local file and the remote file are the same.

			If the local file size is smaller than the remote file size, then the cmdlet will attempt to resume downloading the file and append the remaining bytes to the end of the file.

			If the local file size is the same as the remote file size, then no action is taken and the cmdlet assumes the download already completed.

			If the local file size is larger than the remote file size, then the local file will be overwritten and the entire remote file will be completely re-downloaded. This behavior is the same as using OutFile without Resume .

			If the remote server does not support download resuming, then the local file will be overwritten and the entire remote file will be completely re-downloaded. This behavior is the same as using OutFile without Resume .

			If the local file doesn't exist, then the local file will be created and the entire remote file will be completely downloaded. This behavior is the same as using OutFile without Resume .

			This feature was added in PowerShell 6.1.0.

		.PARAMETER RetryIntervalSec
			Specifies the interval between retries for the connection when a failure code between 400 and 599, inclusive or 304 is received. Also see MaximumRetryCount parameter for specifying number of retries.

		.PARAMETER SessionVariable
			Specifies a variable for which this cmdlet creates a web request session and saves it in the value. Enter a variable name without the dollar sign (`$`) symbol.

			When you specify a session variable, `` creates a web request session object and assigns it to a variable with the specified name in your PowerShell session. You can use the variable in your session as soon as the command completes.

			Unlike a remote session, the web request session isn't a persistent connection. It's an object that contains information about the connection and the request, including cookies, credentials, the maximum redirection value, and the user agent string. You can use it to share state and data among web requests.

			To use the web request session in subsequent web requests, specify the session variable in the value of the WebSession parameter. PowerShell uses the data in the web request session object when establishing the new connection. To override a value in the web request session, use a cmdlet parameter, such as UserAgent or Credential . Parameter values take precedence over values in the web request session.

			You can't use the SessionVariable and WebSession parameters in the same command.

		.PARAMETER SkipCertificateCheck
			Skips certificate validation checks that include all validations such as expiration, revocation, trusted root authority, etc.

			> [!WARNING] > Using this parameter is not secure and is not recommended. This switch is only intended to be used > against known hosts using a self-signed certificate for testing purposes. Use at your own risk.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER SkipHeaderValidation
			Indicates the cmdlet should add headers to the request without validation.

			This switch should be used for sites that require header values that do not conform to standards. Specifying this switch disables validation to allow the value to be passed unchecked. When specified, all headers are added without validation.

			This will disable validation for values passed to the ContentType , Headers , and UserAgent parameters.

			This feature was added in PowerShell 6.0.0.

		.PARAMETER SkipHttpErrorCheck
			This parameter causes the cmdlet to ignore HTTP error statuses and continue to process responses. The error responses are written to the pipeline just as if they were successful.

			This parameter was introduced in PowerShell 7.

		.PARAMETER SslProtocol
			Sets the SSL/TLS protocols that are permissible for the web request. By default all, SSL/TLS protocols supported by the system are allowed. SslProtocol allows for limiting to specific protocols for compliance purposes.

			These values are defined as a flag-based enumeration. You can combine multiple values together to set multiple flags using this parameter. The values can be passed to the SslProtocol parameter as an array of values or as a comma-separated string of those values. The cmdlet will combine the values using a binary-OR operation. Passing values as an array is the simplest option and also allows you to use tab-completion on the values. You may not be able to supply multiple values on all platforms.

			> [!NOTE] > On non-Windows platforms it may not be possible to supply `Tls` or `Tls12` as an option. Support > for `Tls13` is not available on all operating systems and will need to be verified on a per > operating system basis.

			This feature was added in PowerShell 6.0.0 and support for `Tls13` was added in PowerShell 7.1.

		.PARAMETER StatusCodeVariable
			This parameter specifies a variable that's assigned a status code's integer value. The parameter can identify success messages or failure messages when used with the SkipHttpErrorCheck parameter.

			Input the parameter's variable name as a string such as `-StatusCodeVariable "scv"`.

			This parameter was introduced in PowerShell 7.

		.PARAMETER TimeoutSec
			Specifies how long the request can be pending before it times out. Enter a value in seconds. The default value, 0, specifies an indefinite time-out.

			A Domain Name System (DNS) query can take up to 15 seconds to return or time out. If your request contains a host name that requires resolution, and you set TimeoutSec to a value greater than zero, but less than 15 seconds, it can take 15 seconds or more before a WebException is thrown, and your request times out.

		.PARAMETER Token
			The OAuth or Bearer token to include in the request. Token is required by certain Authentication options. It can't be used independently. Token takes a `SecureString` that contains the token. To supply the token, manually use the following:

			` -Uri $uri -Authentication OAuth -Token (Read-Host -AsSecureString)`

			This parameter was introduced in PowerShell 6.0.

		.PARAMETER TransferEncoding
			Specifies a value for the transfer-encoding HTTP response header. The acceptable values for this parameter are:

			- Chunked
			- Compress
			- Deflate
			- GZip
			- Identity

		.PARAMETER UseBasicParsing
		This parameter has been deprecated. Beginning with PowerShell 6.0.0, all Web requests use basic parsing only. This parameter is included for backwards compatibility only and any use of it will have no effect on the operation of the cmdlet.

		.PARAMETER UseDefaultCredentials
		Indicates that the cmdlet uses the credentials of the current user to send the web request. This can't be used with Authentication or Credential and may not be supported on all platforms.

		.PARAMETER UserAgent
			Specifies a user agent string for the web request.

			The default user agent is similar to `Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.15063; en-US) PowerShell/6.0.0` with slight variations for each operating system and platform.

			To test a website with the standard user agent string that is used by most internet browsers, use the properties of the PSUserAgent (/dotnet/api/microsoft.powershell.commands.psuseragent)class, such as Chrome, FireFox, InternetExplorer, Opera, and Safari.

		.PARAMETER WebSession
			Specifies a web request session. Enter the variable name, including the dollar sign (`$`).

			To override a value in the web request session, use a cmdlet parameter, such as UserAgent or Credential . Parameter values take precedence over values in the web request session. Content related headers, such as `Content-Type`, will be also be overridden when a MultipartFormDataContent object is supplied for Body .

			Unlike a remote session, the web request session isn't a persistent connection. It's an object that contains information about the connection and the request, including cookies, credentials, the maximum redirection value, and the user agent string. You can use it to share state and data among web requests.

			To create a web request session, enter a variable name, without a dollar sign, in the value of the SessionVariable parameter of an `` command. `` creates the session and saves it in the variable. In subsequent commands, use the variable as the value of the WebSession parameter.

			You can't use the SessionVariable and WebSession parameters in the same command.


		.EXAMPLE
			-Uri https://blogs.msdn.microsoft.com/powershell/feed/ |
			Format-Table -Property Title, pubDate

			Title                                                                pubDate
			-----                                                                -------
			Join the PowerShell 10th Anniversary Celebration!                    Tue, 08 Nov 2016 23:00:04 +0000
			DSC Resource Kit November 2016 Release                               Thu, 03 Nov 2016 00:19:07 +0000
			PSScriptAnalyzer Community Call - Oct 18, 2016                       Thu, 13 Oct 2016 17:52:35 +0000
			New Home for In-Box DSC Resources                                    Sat, 08 Oct 2016 07:13:10 +0000
			New Social Features on Gallery                                       Fri, 30 Sep 2016 23:04:34 +0000
			PowerShellGet and PackageManagement in PowerShell Gallery and GitHub Thu, 29 Sep 2016 22:21:42 +0000
			PowerShell Security at DerbyCon                                      Wed, 28 Sep 2016 01:13:19 +0000
			DSC Resource Kit September Release                                   Thu, 22 Sep 2016 00:25:37 +0000
			PowerShell DSC and implicit remoting broken in KB3176934             Tue, 23 Aug 2016 15:07:50 +0000
			PowerShell on Linux and Open Source!                                 Thu, 18 Aug 2016 15:32:02 +0000


		.EXAMPLE
			$Cred = Get-Credential
			$Url = "https://server.contoso.com:8089/services/search/jobs/export"
			$Body = @{
				search = "search index=_internal | reverse | table index,host,source,sourcetype,_raw"
				output_mode = "csv"
				earliest_time = "-2d@d"
				latest_time = "-1d@d"
			}
			-Method 'Post' -Uri $url -Credential $Cred -Body $body -OutFile output.csv
			The credentials are prompted for and then stored in `$Cred` and the URL that will be access is defined in `$Url`.
			The `$Body` variable describes the search criteria, specifies CSV as the output mode, and specifies a time period for returned data that starts two days ago and ends one day ago. The body variable specifies values for parameters that apply to the particular REST API with which `` is communicating.
			The `` command is run with all variables in place, specifying a path and file name for the resulting CSV output file.

		.EXAMPLE
			$url = 'https://api.github.com/repos/powershell/powershell/issues'
			$url -FollowRelLink -MaximumFollowRelLink 2


		.EXAMPLE
			$Uri = 'https://api.contoso.com/v2/profile'
			$Form = @{
				firstName  = 'John'
				lastName   = 'Doe'
				email      = 'john.doe@contoso.com'
				avatar     = Get-Item -Path 'c:\Pictures\jdoe.png'
				birthday   = '1980-10-15'
				hobbies    = 'Hiking','Fishing','Jogging'
			}
			$Result =  -Uri $Uri -Method Post -Form $Form
			The profile form requires these fields: `firstName`, `lastName`, `email`, `avatar`, `birthday`, and `hobbies`. The API is expecting an image for the user profile pic to be supplied in the `avatar` field. The API will also accept multiple `hobbies` entries to be submitted in the same form.
			When creating the `$Form` HashTable, the key names are used as form field names. By default, the values of the HashTable will be converted to strings. If a `System.IO.FileInfo` value is present, the file contents will be submitted. If a collection such as arrays or lists are present, the form field will be submitted multiple times.
			By using `Get-Item` on the `avatar` key, the `FileInfo` object will be set as the value. The result is that the image data for `jdoe.png` will be submitted.
			By supplying a list to the `hobbies` key, the `hobbies` field will be present in the submissions once for each list item.

		.NOTES

			Some features may not be available on all platforms.

			Because of changes in .NET Core 3.1, PowerShell 7.0 and higher use the HttpClient.DefaultProxy (/dotnet/api/system.net.http.httpclient.defaultproxy?view=netcore-3.1)Property to determine the proxy configuration.

			The value of this property is different rules depending on your platform:

			- For Windows : Reads proxy configuration from environment variables or, if those are not   defined, from the user's proxy settings. - For macOS : Reads proxy configuration from environment variables or, if those are not defined,   from the system's proxy settings. - For Linux : Reads proxy configuration from environment variables or, in case those are not   defined, this property initializes a non-configured instance that bypasses all addresses.

			The environment variables used for `DefaultProxy` initialization on Windows and Unix-based platforms are:

			- `HTTP_PROXY`: the hostname or IP address of the proxy server used on HTTP requests.

			- `HTTPS_PROXY`: the hostname or IP address of the proxy server used on HTTPS requests.

			- `ALL_PROXY`: the hostname or IP address of the proxy server used on HTTP and HTTPS requests in case `HTTP_PROXY` or `HTTPS_PROXY` are not defined.

			- `NO_PROXY`: a comma-separated list of hostnames that should be excluded from proxying.

		.INPUTS
			System.Object

		.LINK
			https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/?view=powershell-7.1&WT.mc_id=ps-gethelp

		.LINK
			Online Version:

		.LINK
			ConvertTo-Json

		.LINK
			ConvertFrom-Json

		.LINK
			Invoke-WebRequest

	#>
	[CmdletBinding(DefaultParameterSetName = 'StandardMethod')]
	Param(
		[Microsoft.PowerShell.Commands.WebRequestMethod]$Method,

		[Alias('ML')]
		[ValidateRange(1, 2147483647)]
		[Parameter(ParameterSetName = 'RateLimiting', Mandatory)]
		[int]$MaximumFollowRelLink,

		[string]$StatusCodeVariable,

		[switch]$UseBasicParsing,

		#The FreshService portion of the URI, i.e. '/tickets'
		[Parameter(Mandatory)]
		[string]$URISuffix,

		[string]$URIPrefix = $script:BaseURL,

		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,

		[Alias('SV')]
		[string]$SessionVariable,

		[switch]$AllowUnencryptedAuthentication,

		[Microsoft.PowerShell.Commands.WebAuthenticationType]$Authentication,

		[pscredential]
		[System.Management.Automation.CredentialAttribute()]$Credential,

		[switch]$UseDefaultCredentials,

		[ValidateNotNullOrEmpty()]
		[string]$CertificateThumbprint,

		[ValidateNotNull()]
		[X509Certificate]$Certificate,

		[switch]$SkipCertificateCheck,

		[Microsoft.PowerShell.Commands.WebSslProtocol]$SslProtocol,

		[securestring]$Token,

		[string]$UserAgent,

		[switch]$DisableKeepAlive,

		[ValidateRange(0, 2147483647)]
		[int]$TimeoutSec,

		[System.Collections.IDictionary]$Headers = $script:FFAuthHeader,

		[ValidateRange(0, 2147483647)]
		[int]$MaximumRedirection,

		[ValidateRange(0, 2147483647)]
		[int]$MaximumRetryCount,

		[ValidateRange(1, 2147483647)]
		[int]$RetryIntervalSec,

		[Parameter(ParameterSetName = 'RateLimiting')]
		[ValidateRange(1, 2147483647)]
		[int]$RateLimitIntervalSec = 5,

		[Parameter(ParameterSetName = 'StandardMethodNoProxy', Mandatory)]
		[switch]$NoProxy,

		[Parameter(ParameterSetName = 'StandardMethod')]
		[uri]$Proxy,

		[Parameter(ParameterSetName = 'StandardMethod')]
		[pscredential]
		[System.Management.Automation.CredentialAttribute()]$ProxyCredential,

		[Parameter(ParameterSetName = 'StandardMethod')]
		[switch]$ProxyUseDefaultCredentials,

		[Parameter(ValueFromPipeline)]
		[System.Object]$Body,

		[System.Collections.IDictionary]$Form,

		[string]$ContentType,

		[ValidateSet('chunked', 'compress', 'deflate', 'gzip', 'identity')]
		[string]$TransferEncoding,

		[string]$InFile,

		[string]$OutFile,

		[switch]$PassThru,

		[switch]$Resume,

		[switch]$SkipHttpErrorCheck,

		[switch]$PreserveAuthorizationOnRedirect,

		[switch]$SkipHeaderValidation,

		[Parameter(ParameterSetName = 'RateLimiting')]
		[int]$Depth = 0,

		[switch]$SkipPerPageAddition,

		[switch]$EnableException = $true
	)

	Begin {
		Write-PSFMessage -Target $PSBoundParameters -Level Debug -Message "Running $($MyInvocation.MyCommand) using parameter set $($PSCmdlet.ParameterSetName) with these parameters"

		#Add check to see if headers or

		$Defaults = @{
			Header = $Headers
		}

		Write-PSFMessage -Level Debug -Message 'Adding default parameters to PSBoundParameters'
		$Defaults.GetEnumerator() | ForEach-Object { $PSBoundParameters.($_.Key) = $_.Value }

		$LockedParams = @{
			ResponseHeadersVariable = 'ResponseHeaders'
			FollowRelLink           = $true
			URI                     = $URIPrefix + $URISuffix
		}
		Write-PSFMessage -Level Debug -Message 'Adding locked parameters to PSBoundParameters'
		$LockedParams.GetEnumerator() | ForEach-Object { $PSBoundParameters.($_.Key) = $_.Value }

		$WrapperParamNames = 'Depth', 'RateLimitIntervalSec', 'URIPrefix', 'URISuffix', 'SkipPerPageAddition', 'EnableException'
		Write-PSFMessage -Level Debug -Message 'Removing wrapper only parameters from PSBoundParameters'
		$WrapperParamNames | ForEach-Object {
			#This is because removing entries from PSBoundParameters returns a bool
			if ($PSBoundParameters.ContainsKey($_)) { $PSBoundParameters.Remove($_) | Out-Null }
		}
		#This is simply for better logging and does not affect the parameters passed to Invoke-RestMethod
		if ($null -eq $Method) { $Method = 'GET' }
	} #begin

	Process {
		$OldRelLink = ''

		# if ($Method -eq 'GET') {
		# 	if (-Not $PSBoundParameters.ContainsKey('Body')) {
		# 		$Body = @{}
		# 	}
		# 	if ((-Not $Body.ContainsKey('per_page')) -and (-Not $SkipPerPageAddition.IsPresent)) {
		# 		Write-PSFMessage -Level Debug -Message 'Adding per_page=100 to the request body'
		# 		$Body.'per_page' = 100
		# 		$PSBoundParameters.Body = $Body
		# 	}
		# } elseif ($Method -in 'POST', 'PUT') {
		# 	$PSBoundParameters.ContentType = 'application/json'
		# 	if (
		# 		$PSBoundParameters.ContainsKey('Body') -and
		# 		$PSBoundParameters.Body -isnot [string] -and
		# 		(-Not $Body.ContainsKey('ContentType'))) {
		# 		#I don't remember why this line is here
		# 		$PSBoundParameters.Body = $Body | ConvertTo-Json -Depth 20 -EscapeHandling EscapeNonAscii
		# 	}
		# }

		Write-PSFMessage -Level Debug -Target $PSBoundParameters -Message 'Running Invoke-RestMethod with these parameters'

		if ($PSBoundParameters.ContainsKey('Body')) {
			$JSONBody = if ($Body -isnot [string]) { $Body | ConvertTo-Json -Depth 20 -EscapeHandling EscapeNonAscii } else { $Body }
			Write-PSFMessage -Level Debug -Target $Body -Message "Body of $Method request to $($PSBoundParameters.URI) is:`r`n$JSONBody"
		}
		#$Result = Invoke-RestMethod @PSBoundParameters -ErrorAction Stop
		try {
			$Result = Invoke-RestMethod @PSBoundParameters
		} catch {
			#Write-PSFMessage -Target $_ -Level Warning -Message 'Error in target'
			$IRMError = $_
			Write-PSFMessage -Level Debug -Message 'Set $IRMError to caught error object from Invoke-RestMethod' -Breakpoint -Target $IRMError

			$Splat = @{
				Message         = "Failed to $Method request to $($PSBoundParameters.URI)"
				ErrorRecord     = $IRMError
				Target          = $PSBoundParameters.URI
				EnableException = $EnableException
			}

			if (
				$null -ne $IRMError.ErrorDetails -and
				$null -ne $IRMError.ErrorDetails.Message
			) {
				$APIErrorMessage = Get-APIErrorMessage -ErrorJSON $IRMError.ErrorDetails.Message

				if ($null -ne $APIErrorMessage) {
					$Splat.Message = $Splat.Message + " with this message: $APIErrorMessage"
					$Splat.Exception = $APIErrorMessage
				}
			}

			Stop-PSFFunction @Splat
			#Write-PSFMessage -Level Error -ErrorRecord $IRMError -EnableException $EnableException -Message "Failed to $Method request to $($PSBoundParameters.URI)"
		}

		Write-Output $Result

		Write-PSFMessage -Level Debug -Target $ResponseHeaders -Message 'Receieved the attached response headers'

		#The below section is borrowed from the FreshService.Tools module on PSGallery
		if (
			($PSCmdlet.ParameterSetName -eq 'RateLimiting') -and
			($ResponseHeaders.ContainsKey('Link')) -and
			($null -ne $ResponseHeaders.Link) -and
			('' -ne $ResponseHeaders.Link)
		) {
			$Depth += 1
			Write-PSFMessage -Level SomewhatVerbose -Message "Next Link: $($ResponseHeaders.Link) at Depth: $Depth"
			# Extract the URL from the link text which looks like '<https::domain.freshservice.com/api/v2/tickets?per_page=100&page=21>; Rel="next"'
			$RelLink = [regex]::match($ResponseHeaders.Link, '\<([^\>]+)\>.*').Groups[1].Value

			# If the link has not changed, don't follow it
			if ($RelLink -ne $OldRelLink) {
				Write-PSFMessage "Rate Limit - Remaining $($ResponseHeaders.'X-RateLimit-Remaining'); Used $($ResponseHeaders.'X-RateLimit-Used-CurrentRequest'); Max $($ResponseHeaders.'X-RateLimit-Total')"

				#if (($RateLimitUsedCurrentRequest * $MaximumFollowRelLink) -ge $RateLimitRemaining) {
				if ($RateLimitRemaining -eq 0) {
					Write-PSFMessage -Level Warning "Sleeping for $RateLimitIntervalSec seconds (until $((Get-Date).AddSeconds($RateLimitIntervalSec))) to evade API Rate Limit"
					Start-Sleep -Seconds $RateLimitIntervalSec
				}

				Write-PSFMessage "Requesting next set of results from $RelLink"
				$ReRunParams = $PSBoundParameters
				$LockedParams.Keys | ForEach-Object { $ReRunParams.Remove($_) }
				$ReRunParams.UriSuffix = $RelLink.Replace($BaseURL, '')
				$ReRunParams.Depth = $Depth

				$Results = Invoke-FSAPI @ReRunParams

				Write-Output $Results

				#I still have to verify this
				#Write-PSFMessage "Checking if results contains an error"
				#if ($Results -is [HashTable] -and $Results.ContainsKey('Error') -and $Results.Error) {
				#	Throw "$Me : Encountered error getting additional results.  $($ErrorObject.Code) : $($ErrorObject.Note) from: $RelLink"
				#} else {
				#	Write-Output $Results
				#}
				$OldRelLink = $RelLink
			} #if ($RelLink -ne $OldRelLink)
		} #if (($PSCmdlet.ParameterSetName -eq 'RateLimiting') -and ($ResponseHeaders.ContainsKey('Link')) -and ($null -ne $ResponseHeaders.Link) -and ('' -ne $ResponseHeaders.Link))
	} #process
}
