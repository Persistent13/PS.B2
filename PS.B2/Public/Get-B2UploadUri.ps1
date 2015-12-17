function Get-B2UploadUri
{
	<#
	.Synopsis
		Short description
	.DESCRIPTION
		Long description
	.EXAMPLE
		Example of how to use this cmdlet
	.EXAMPLE
		Another example of how to use this cmdlet
	.INPUTS
		Inputs to this cmdlet (if any)
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
	[CmdletBinding(PositionalBinding=$false)]
	[Alias()]
	[OutputType('PS.B2.UploadUri')]
	Param
	(
		# The ID of the bucket to query.
		[Parameter(Mandatory=$true,
				   ValueFromPipelineByPropertyName=$true,
				   ValueFromPipeline=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$BucketID,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$false,
				   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[Uri]$ApiUri = $script:SavedB2ApiUri,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_get_upload_url"
	}
	Process
	{
		foreach($bucket in $BucketID)
		{
			[String]$sessionBody = @{'bucketId'=$bucket} | ConvertTo-Json
			$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
			$bbReturnInfo = [PSCustomObject]@{
				'BucketID' = $bbInfo.bucketId
				'UploadUri' = $bbInfo.uploadUrl
				'Token' = $bbInfo.authorizationToken
			}
			# bbReturnInfo is returned after Add-ObjectDetail is processed.
			Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.UploadUri'
		}
	}
}