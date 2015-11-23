function New-B2Bucket
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
	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact='Medium')]
	[Alias()]
	[OutputType()]
	Param
	(
		[Parameter(Mandatory=$true,
				   ValueFromPipelineByPropertyName=$false,
				   Position=0)]
		[String[]]$BucketName,
		[Parameter(Mandatory=$true,
				   ValueFromPipelineByPropertyName=$false,
				   Position=1)]
        [ValidateSet('allPublic','allPrivate')]
		[String]$BucketType
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$global:AuthorizationToken}
		[Uri]$b2ApiUri = "$script:SavedB2ApiUrl/b2api/v1/b2_create_bucket?accountId=$script:SavedB2AccountID&bucketName=$BucketName&bucketType=$BucketType"
	}
	Process
	{
		if($PSCmdlet.ShouldProcess($b2ApiUri))
        {
            foreach($bucket in $BucketName)
            {
			    Invoke-RestMethod -Headers $sessionHeaders -Uri $b2ApiUri
            }
		}
	}
	End
	{
	}
}