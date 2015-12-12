function Get-B2Blob
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
	[Alias('gb2bi')]
	[OutputType('PS.B2.BlobProperty')]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String[]]$FileID,
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
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_get_file_info"
	}
	Process
	{
		foreach($file in $FileID)
		{
			[String]$sessionBody = @{'fileId'=$file} | ConvertTo-Json
			$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
			$bbReturnInfo = [PSCustomObject]@{
				'FileName' = $bbInfo.fileName
				'FileInfo' = $bbInfo.fileInfo
				'ContentType' = $bbInfo.contentType
				'ContentLength' = $bbInfo.contentLength
				'BucketID' = $bbInfo.bucketId
				'AccountID' = $bbInfo.accountId
				'ContentSHA1' = $bbInfo.contentSha1
				'FileID' = $bbInfo.fileId
			}
			# bbReturnInfo is returned after Add-ObjectDetail is processed.
			Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.BlobProperty'
		}
	}
}