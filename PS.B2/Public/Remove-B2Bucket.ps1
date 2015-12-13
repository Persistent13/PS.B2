function Remove-B2Bucket
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
	[CmdletBinding(SupportsShouldProcess=$true,
				   ConfirmImpact='High')]
	[Alias('rb2b')]
	[OutputType('PS.B2.Bucket')]
	Param
	(
		# The ID of the new B2 bucket.
		[Parameter(Mandatory=$true,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateLength(1,50)]
		[String[]]$BucketID,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$false,
				   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[Uri]$ApiUri = $script:SavedB2ApiUri,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$AccountID = $script:SavedB2AccountID,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=4)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_delete_bucket"
	}
	Process
	{
		foreach($bucket in $BucketID)
        {
			if($Force -or $PSCmdlet.ShouldProcess($bucket, "Delete bucket."))
        	{
				[String]$sessionBody = @{'accountId'=$AccountID;'bucketId'=$bucket} | ConvertTo-Json
			    $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
				$bbReturnInfo = [PSCustomObject]@{
					'BucketName' = $bbInfo.bucketName
					'BucketID' = $bbInfo.bucketId
					'BucketType' = $bbInfo.bucketType
					'AccountID' = $bbInfo.accountId
				}
				# bbReturnInfo is returned after Add-ObjectDetail is processed.
				Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.Bucket'
			}
		}
	}
}