function Hide-B2Blob
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
	[CmdletBinding(SupportsShouldProcess=$true)]
	[Alias('hb2b')]
	[OutputType('PS.B2.Blob')]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String[]]$FileName,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$BucketID,
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
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_hide_file"
	}
	Process
	{
		foreach($file in $FileName)
		{
			if($Force -or $PSCmdlet.ShouldProcess("Hiding file $file in bucket $BucketID."))
			{
				[String]$sessionBody = @{'bucketId'=$BucketID;'fileName'=$file} | ConvertTo-Json
				$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
				$bbReturnInfo = [PSCustomObject]@{
					'FileName' = $bbInfo.fileName
					'Size' = $bbInfo.size
					'UploadTime' = $bbInfo.uploadTimestamp
					'Action' = $bbInfo.action
					'FileID' = $bbInfo.fileId
				}
				# bbReturnInfo is returned after Add-ObjectDetail is processed.
				Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.Blob'
			}
		}
	}
}