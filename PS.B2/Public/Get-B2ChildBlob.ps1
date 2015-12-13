function Get-B2ChildBlob
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
	[Alias('gb2cb')]
	[OutputType('PS.B2.Blob')]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String[]]$BucketID,
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
		[String]$AccountID = $script:SavedB2AccountID,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,
				   Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_list_file_names"
	}
	Process
	{
		foreach($bucket in $BucketID)
		{
			[String]$sessionBody = @{'bucketId'=$bucket} | ConvertTo-Json
			$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
			foreach($info in $bbInfo.files)
			{
				$bbReturnInfo = [PSCustomObject]@{
					'FileName' = $info.fileName
					'Size' = $info.size
					'UploadTime' = $info.uploadTimestamp
					'Action' = $info.action
					'FileID' = $info.fileId
				}
				# bbReturnInfo is returned after Add-ObjectDetail is processed.
				Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.Blob'
			}
		}
	}
}