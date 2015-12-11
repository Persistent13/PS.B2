function Get-B2Bucket
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
	#>
	[CmdletBinding(SupportsShouldProcess=$false)]
	[Alias()]
	[OutputType('PS.B2.Bucket')]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$false,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[Uri]$ApiUri = $script:SavedB2ApiUri,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$AccountID = $script:SavedB2AccountID,
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
		[String]$sessionBody = @{'accountId'=$AccountID} | ConvertTo-Json
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_list_buckets"
	}
	Process
	{
		$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
		foreach($info in $bbInfo.buckets)
		{
			$bbReturnInfo = [PSCustomObject]@{
				'BucketName' = $info.bucketName
				'BucketID' = $info.bucketId
				'BucketType' = $info.bucketType
				'AccountID' = $info.accountId
			}
			# bbReturnInfo is returned after Add-ObjectDetail is processed.
			Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.Bucket'
		}
	}
}