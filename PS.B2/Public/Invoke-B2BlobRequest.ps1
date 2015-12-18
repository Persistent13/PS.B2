function Invoke-B2BlobRequest
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
				   ConfirmImpact='Low')]
	[Alias('ib2br')]
	[OutputType()]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(ParameterSetName='FileID',
				   Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$FileID,
		# The Uri for the B2 Api query.
		[Parameter(ParameterSetName='FileName',
				   Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$FileName,
		# The Uri for the B2 Api query.
		[Parameter(ParameterSetName='FileName',
				   Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$BucketName,
		# The Uri for the B2 Api query.
		[Parameter(ParameterSetName='FileName',
				   Mandatory=$true,
				   Position=3)]
		[Parameter(ParameterSetName='FileID',
				   Mandatory=$true,
				   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$OutFile,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$false,ParameterSetName='FileName')]
		[Parameter(Mandatory=$false,ParameterSetName='FileID')]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[Uri]$ApiDownloadUri = $script:SavedB2DownloadUri,
		# The authorization token for the B2 account.
		[Parameter(Mandatory=$false,ParameterSetName='FileName')]
		[Parameter(Mandatory=$false,ParameterSetName='FileID')]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		if(-not (Test-Path -Path $OutFile -IsValid))
		{
			throw 'The file path given is not valid.`n`rThe file cannot be saved.'
		}
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
	}
	Process
	{
		# The process context will change based on the name of the paramter set used.
		switch($PSCmdlet.ParameterSetName)
		{
			'FileName'
			{
				[Uri]$b2ApiUri = "${ApiDownloadUri}b2api/v1/b2_download_file_by_id?fileId=$FileID"
				if($PSCmdlet.ShouldProcess($FileID, "Download to the path $OutFile."))
				{
					try
					{
						Invoke-RestMethod -Method Get -Uri $b2ApiUri -Headers $sessionHeaders -OutFile $OutFile
					}
					catch
					{
						$errorDetail = $_.Exception.Message
						Write-Error -Exception "Unable to upload the file.`n`r$errorDetail" `
							-Message "Unable to upload the file.`n`r$errorDetail" -Category InvalidOperation
					}
				}
			}
			'FileID'
			{
				[Uri]$b2ApiUri = "${ApiDownloadUri}file/$BucketName/$FileName"
				if($PSCmdlet.ShouldProcess($FileName, "Download to the path $OutFile."))
				{
					try
					{
						Invoke-RestMethod -Method Get -Uri $b2ApiUri -Headers $sessionHeaders -OutFile $OutFile
					}
					catch
					{
						$errorDetail = $_.Exception.Message
						Write-Error -Exception "Unable to upload the file.`n`r$errorDetail" `
							-Message "Unable to upload the file.`n`r$errorDetail" -Category InvalidOperation
					}
				}
			}
		}
	}
}