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
	[CmdletBinding(SupportsShouldProcess=$true,
				   ValueFromPipelineByPropertyName=$false,
				   ConfirmImpact='Low')]
	[Alias()]
	[OutputType()]
	Param
	(
		# The name of the new B2 bucket.
		[Parameter(Mandatory=$true,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[ValidateLength(1,50)]
		[String[]]$BucketName,
		# What type of bucket, public or private, to create.
		[Parameter(Mandatory=$true,
				   Position=1)]
        [ValidateSet('allPublic','allPrivate')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$BucketType,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$false,
				   Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[Uri]$ApiUri = $script:SavedB2ApiUri,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=4)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$AccountID = $script:SavedB2AccountID,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=5)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_create_bucket?accountId=$AccountID&bucketName=$BucketName&bucketType=$BucketType"
	}
	Process
	{
		if($Force -or $PSCmdlet.ShouldProcess("Creating bucket $BucketName of type $BucketType."))
        {
            foreach($bucket in $BucketName)
            {
			    Invoke-RestMethod -Method Get -Headers $sessionHeaders -Uri $b2ApiUri
            }
		}
	}
}