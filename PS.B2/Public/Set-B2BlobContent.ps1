function Set-B2BlobContent
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
.INPUTS
	Inputs to this cmdlet (if any)
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	General notes
.COMPONENT
	The component this cmdlet belongs to
.ROLE
	The role this cmdlet belongs to
.FUNCTIONALITY
	The functionality that best describes this cmdlet
#>
	[CmdletBinding(SupportsShouldProcess=$true,
				   ConfirmImpact='Medium')]
	[Alias('sb2bc')]
	[OutputType('PS.B2.BlobProperty')]
	Param
	(
		# The ID of the bucket to update.
		[Parameter(Mandatory=$true, 
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$BucketID,
		# Param2 help description
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[Alias('FullName')]
		[String[]]$Path,
		# Used to bypass confirmation prompts.
		[Parameter(Mandatory=$false,
				   Position=2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[Switch]$Force
	)
	
	Begin
	{
		$b2Upload = Get-B2UploadUri -BucketID $BucketID
	}
	Process
	{
		foreach($file in $Path)
		{
			if($Force -or $PSCmdlet.ShouldProcess($file, "Uploading to bucket $BucketID."))
			{
				try
				{
					[String]$b2FileName = (Get-Item -Path $file).Name
					# System.Web.MimeMapping is imported on module import from Set-OutputTypes
					[String]$b2FileMime = [System.Web.MimeMapping]::GetMimeMapping($file)
					[String]$b2FileSHA1 = (Get-FileHash -Path $file -Algorithm SHA1).Hash
					[String]$b2FileAuthor = (Get-Acl -Path $file).Owner
					$b2FileAuthor = $b2FileAuthor.Substring($b2FileAuthor.IndexOf('\')+1)
					[Hashtable]$sessionHeaders = @{
						'Authorization' = $b2Upload.Token
						'X-Bz-File-Name' = $b2FileName
						'Content-Type' = $b2FileMime
						'X-Bz-Content-Sha1' = $b2FileSHA1
						'X-Bz-Info-Author' = $b2FileAuthor
					}
					
					$bbInfo = Invoke-RestMethod -Method Post -Uri $b2Upload.UploadUri -Headers $sessionHeaders -InFile $file
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