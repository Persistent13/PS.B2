function Get-B2BlobProperty
{
<#
.Synopsis
	The Get-B2BlobProperty cmdlet will pull blob information.
.DESCRIPTION
	The Get-B2BlobProperty cmdlet will pull blob information on the specified file ID.
	
	An API key is required to use this cmdlet.
.EXAMPLE
	Get-B2BlobProperty -FileID 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001
	
	FileName      : akitty.jpg
	FileInfo      :
	ContentType   : image/jpeg
	ContentLength : 122573
	BucketID      : e73ede9c9c8412db49f60715
	AccountID     : 7eecc42b9675
	ContentSHA1   : a01a21253a07fb08a354acd30f3a6f32abb76821
	FileID        : 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001
	
	The cmdlet above returns the blob properties for the FileID given.
.EXAMPLE
	PS C:\>Get-B2Bucket | Get-B2ChildBlob | Get-B2BlobProperty
	
	FileName      : akitty.jpg
	FileInfo      :
	ContentType   : image/jpeg
	ContentLength : 122573
	BucketID      : e73ede9c9c8412db49f60715
	AccountID     : 7eecc42b9675
	ContentSHA1   : a01a21253a07fb08a354acd30f3a6f32abb76821
	FileID        : 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001
	
	FileName      : adoggy.jpg
	FileInfo      : @{author=John}
	ContentType   : image/jpeg
	ContentLength : 165237
	BucketID      : e73ede9c9c8412db49f60717
	AccountID     : 7eecc42b9675
	ContentSHA1   : 3100d797d8c0282aeb0afac63f0795117892d2fd
	FileID        : 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0002
	
	The cmdlets above get the blob properties for all blobs in all buckets.
.INPUTS
   	System.String
   
       	This cmdlet takes the FieldID, AccountID and ApiToken as strings.
	   
   	System.Uri
   
       	This cmdlet takes the ApiUri as a Uri.
.OUTPUTS
   	PS.B2.BlobProperty
   
       	This cmdlet will output a PS.B2.BlobProperty object holding the blob properties.
.ROLE
   	PS.B2
.FUNCTIONALITY
   	PS.B2
#>
	[CmdletBinding(SupportsShouldProcess=$false)]
	[Alias('gb2bi')]
	[OutputType('PS.B2.BlobProperty')]
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