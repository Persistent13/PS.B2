function Remove-B2BlobVersion
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
	[Alias('rb2bv')]
	[OutputType('PS.B2.RemoveBlob')]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String[]]$FileID,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
		[String[]]$FileName,
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
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		if($FileID.Count -ne $FileName.Count)
		{
			throw 'A file ID must be accompanied by its file name.'
		}
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Array]$b2FileArray = $FileID, $FileName
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_delete_file_version"
	}
	Process
	{
		# Array [0][$i] is the file ID; [1][$i] is the file name.
		for($i=0; $i -lt $b2FileArray[0].Count; $i++)
		{
			if($Force -or $PSCmdlet.ShouldProcess($b2FileArray[0][$i], 'Remove file version.'))
			{
				[String]$sessionBody = @{'fileId'=$b2FileArray[0][$i];'fileName'=$b2FileArray[1][$i]} | ConvertTo-Json
				$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
				$bbReturnInfo = [PSCustomObject]@{
					'FileName' = $bbInfo.fileName
					'FileID' = $bbInfo.fileId
				}
				# bbReturnInfo is returned after Add-ObjectDetail is processed.
				Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.RemoveBlob'
			}
		}
	}
}