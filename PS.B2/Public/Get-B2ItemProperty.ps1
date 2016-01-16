function Get-B2ItemProperty
{
<#
.Synopsis
	The Get-B2ItemProperty cmdlet will pull file information.
.DESCRIPTION
	The Get-B2ItemProperty cmdlet will pull file information on the specified file ID.
	
	An API key is required to use this cmdlet.
.EXAMPLE
	Get-B2ItemProperty -ID 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001
	
	Name          : akitty.jpg
	ItemInfo      :
	ContentType   : image/jpeg
	ContentLength : 122573
	BucketID      : e73ede9c9c8412db49f60715
	AccountID     : 7eecc42b9675
	ContentSHA1   : a01a21253a07fb08a354acd30f3a6f32abb76821
	ID            : 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001
	
	The cmdlet above returns the item properties for the ID given.
.EXAMPLE
	PS C:\>Get-B2Bucket | Get-B2ChildItem | Get-B2ItemProperty
	
	Name          : akitty.jpg
	ItemInfo      :
	ContentType   : image/jpeg
	ContentLength : 122573
	BucketID      : e73ede9c9c8412db49f60715
	AccountID     : 7eecc42b9675
	ContentSHA1   : a01a21253a07fb08a354acd30f3a6f32abb76821
	ID            : 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001
	
	Name          : adoggy.jpg
	ItemInfo      : @{author=John}
	ContentType   : image/jpeg
	ContentLength : 165237
	BucketID      : e73ede9c9c8412db49f60717
	AccountID     : 7eecc42b9675
	ContentSHA1   : 3100d797d8c0282aeb0afac63f0795117892d2fd
	ID            : 4_ze73ede9c9c8412db49f60715_f100b4e93fbae6252_d20150824_m224353_c900_v8881000_t0002
	
	The cmdlets above get the file properties for all files in all buckets.
.INPUTS
	System.String
	
		This cmdlet takes the FieldID, AccountID and ApiToken as strings.
		
	System.Uri
	
		This cmdlet takes the ApiUri as a Uri.
.OUTPUTS
	PS.B2.FileProperty
	
		This cmdlet will output a PS.B2.FileProperty object holding the file properties.
.LINK
	https://www.backblaze.com/b2/docs/
.ROLE
	PS.B2
.FUNCTIONALITY
	PS.B2
#>
	[CmdletBinding(SupportsShouldProcess=$false)]
	[Alias('gb2ip')]
	[OutputType('PS.B2.FileProperty')]
	Param
	(
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String[]]$ID,
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
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_get_file_info"
	}
	Process
	{
        # Loops through each item in the ID array and returns the file info.
		foreach($file in $ID)
		{
			try
			{
				[String]$sessionBody = @{'fileId'=$file} | ConvertTo-Json
				$bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
				$bbReturnInfo = [PSCustomObject]@{
					'Name' = $bbInfo.fileName
					'FileInfo' = $bbInfo.fileInfo
					'ContentType' = $bbInfo.contentType
					'ContentLength' = $bbInfo.contentLength
					'BucketID' = $bbInfo.bucketId
					'AccountID' = $bbInfo.accountId
					'ContentSHA1' = $bbInfo.contentSha1
					'ID' = $bbInfo.fileId
				}
				# bbReturnInfo is returned after Add-ObjectDetail is processed.
				Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.FileProperty'
			}
			catch
			{
				$errorDetail = $_.Exception.Message
				Write-Error -Exception "Unable to retrieve the file information.`n`r$errorDetail" `
					-Message "Unable to retrieve the file information.`n`r$errorDetail" -Category ReadError
			}
		}
	}
}