function Set-B2Bucket
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
	[Alias('sb2b')]
	[OutputType('PS.B2.Bucket')]
	Param
	(
		# The ID of the bucket to update.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[ValidateLength(1,50)]
		[String[]]$BucketID,
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
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_update_bucket"
	}
	Process
	{
		foreach($bucket in $BucketID)
		{
			if($Force -or $PSCmdlet.ShouldProcess($bucket, "Set bucket type to $BucketType."))
			{
				try
				{
					[String]$sessionBody = @{'accountId'=$AccountID;'bucketId'=$bucket;'bucketType'=$BucketType} | ConvertTo-Json
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
				catch
				{
					$errorDetail = $_.Exception.Message
					Write-Error -Exception "Unable to make the bucket change.`n`r$errorDetail" `
						-Message "Unable to make the bucket change.`n`r$errorDetail" -Category InvalidOperation
				}
			}
		}
	}
}