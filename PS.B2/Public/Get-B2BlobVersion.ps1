function Get-B2BlobVersion
{
<#
.Synopsis
	The Get-B2BlobVersion cmdlet retirives blob version info.
.DESCRIPTION
	The Get-B2BlobVersion cmdlet retirives blob version info.
	Bucket information required for this cmdlet can be retirived with Get-B2Bucket.
	
	An API key is required to use this cmdlet.
.EXAMPLE
	Get-B2BlobVersion -BucketID BUCKET_ID
	
	FileName   : files/hello.txt
	Size       : 6
	UploadTime : 1439162596000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f100920ddab886245_d20150809_m232316_c100_v0009990_t0003
	
	FileName   : files/world.txt
	Size       : 0
	UploadTime : 1439162603000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f100920ddab886247_d20150809_m232323_c100_v0009990_t0005
	
	FileName   : files/world.txt
	Size       : 6
	UploadTime : 1439162596000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f100920ddab886246_d20150809_m232316_c100_v0009990_t0003
	
	The above cmdlet will return the verion information for all file versions in the given bucket.
.EXAMPLE
	PS C:\>Get-B2Bucket | Get-B2BlobVersion
	
	FileName   : files/hello.txt
	Size       : 6
	UploadTime : 1439162596000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f100920ddab886245_d20150809_m232316_c100_v0009990_t0003
	
	FileName   : files/world.txt
	Size       : 0
	UploadTime : 1439162603000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f100920ddab886247_d20150809_m232323_c100_v0009990_t0005
	
	FileName   : files/world.txt
	Size       : 6
	UploadTime : 1439162596000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f100920ddab886246_d20150809_m232316_c100_v0009990_t0003
	
	The above cmdlet will return the verion information for all file versions in all buckets.
.INPUTS
	System.String
			
		This cmdlet takes the AccountID and ApplicationKey as strings.
		
   	System.Uri
   
   		This cmdlet takes the ApiUri as a Uri.
.OUTPUTS
	PS.B2.Blob
	
		The cmdlet will output a PS.B2.Blob object holding file version info.
.ROLE
	PS.B2
.FUNCTIONALITY
	PS.B2
#>
	[CmdletBinding(SupportsShouldProcess=$false)]
	[Alias('gb2bv')]
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
		[String]$ApiToken = $script:SavedB2ApiToken
	)
	
	Begin
	{
		[Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
		[Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_list_file_versions"
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