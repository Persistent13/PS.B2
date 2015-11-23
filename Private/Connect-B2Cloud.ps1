function Connect-B2Cloud
{
<#
.Synopsis
	Establishes initial connection to the B2 cloud API.
.DESCRIPTION
	Long description
.EXAMPLE
	Connect-B2Cloud #THINGS 
.EXAMPLE
	Another example of how to use this cmdlet
.INPUTS
	None
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	General notes
.COMPONENT
	The component this cmdlet belongs to
.ROLE
	The role this cmdlet belongs to
.FUNCTIONALITY
	The functionality that best describes this cmdlet
#>
	[CmdletBinding()]
	[Alias('cb2c')]
	[OutputType()]
	Param
	(
		# Your Backblaze account ID.
		[Parameter(Mandatory=$false,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$AccountID,
		
		# Your Backblaze application key.
		[Parameter(Mandatory=$false,
                   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[Alias('Key')]
		[String]$ApplicationKey
	)
	
	Begin
	{
        if (-not $AccountID)
        {
            $AccountID = (Get-Credential -Message 'Enter your account ID key below.' -UserName AccountID).GetNetworkCredential().Password
        }
        if(-not $ApplicationKey)
        {
            $ApplicationKey = (Get-Credential -Message 'Enter your application key key below.' -UserName ApplicationKey).GetNetworkCredential().Password
        }
		[Hashtable]$sessionHeaders = @{$AccountID=$ApplicationKey;'Content-Type'='application/json'}
		[Uri]$b2ApiUri = 'https://api.backblaze.com/b2api/v1/b2_authorize_account'
	}
	Process
	{
		try
		{
			$b2ReturnInfo = Invoke-RestMethod -Method Get -Uri $b2ApiUri -Headers $sessionHeaders
            $script:SavedB2AccountID = $AccountID
			$script:SavedB2AuthorizationToken = $b2ReturnInfo.authorizationToken
            $script:SavedB2ApiUrl = $b2ReturnInfo.apiUrl
            $script:SavedB2DownloadUrl = $b2ReturnInfo.downloadUrl
		}
		catch
		{
            Write-Error -Exception 'Unable to authenticate with given APIKey.' `
                -Message 'Unable to authenticate with given APIKey.' -Category AuthenticationError
		}
	}
	End
	{
		Write-Output $b2ReturnInfo
	}
}