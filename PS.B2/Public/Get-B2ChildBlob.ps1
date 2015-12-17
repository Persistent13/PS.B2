function Get-B2ChildBlob
{
<#
.Synopsis
	The Get-B2ChildBlob cmdlet will return the file list of a bucket.
.DESCRIPTION
	The Get-B2ChildBlob cmdlet will return the file list of a bucket.
	By default the selection is limited to the first 1000 items, to increment the selection use the
	StartName paramter to specifiy the starting file's name.
	
	An API key is required to use this cmdlet.
.EXAMPLE
	Get-B2ChildBlob -BucketID 4a48fe8875c6214145260818
	
	FileName   : files/hello.txt
	Size       : 6
	UploadTime : 1439083733000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6b_d20150809_m012853_c100_v0009990_t0000
	
	FileName   : files/world.txt
	Size       : 6
	UploadTime : 1439083734000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6c_d20150809_m012854_c100_v0009990_t0000
	
	The cmdlet above will list all files in the given bucket upto the first 1000.
.EXAMPLE
	PS C:\>Get-B2ChildBlob -BucketID 4a48fe8875c6214145260818 -StartName files/world.txt -FileCount 3
	
	FileName   : files/world.txt
	Size       : 6
	UploadTime : 1439083734000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6c_d20150809_m012854_c100_v0009990_t0000
	
	FileName   : files/how.txt
	Size       : 6
	UploadTime : 1439083734000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f8aa4ba650fe24e6c_d20150809_m012854_c100_v0009990_t0000
	
	FileName   : files/are.txt
	Size       : 6
	UploadTime : 1439083734000
	Action     : upload
	FileID     : 4_z27c88f1d182b150646ff0b16_f1004hf950fe24e6c_d20150809_m012854_c100_v0009990_t0000
	
	The cmdlet above will start listing the files from the files/world.txt file and then three
	preceeding files after that.
.LINK
	https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
	[CmdletBinding(SupportsShouldProcess=$false)]
	[Alias('gb2cb')]
	[OutputType('PS.B2.Blob')]
	Param
	(
		# The ID of the bucket to query.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String[]]$BucketID,
		# The name of the file to start listing from.
		[Parameter(Mandatory=$false,
				   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String]$StartName,
		# The number of files to return; the default and max is 1000.
		[Parameter(Mandatory=$false,
				   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[UInt32]$FileCount = 1000,
		# The Uri for the B2 Api query.
		[Parameter(Mandatory=$false,
				   Position=2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[Uri]$ApiUri = $script:SavedB2ApiUri,
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
			[String]$sessionBody = @{'bucketId'=$bucket;'maxFileCount'=$FileCount;'startFileName'=$StartName} | ConvertTo-Json
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