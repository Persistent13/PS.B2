function Invoke-B2ItemUpload
{
<#
.SYNOPSIS
    The Invoke-B2ItemUpload cmdlet uploads files to a specified bucket.
.DESCRIPTION
    The Invoke-B2ItemUpload cmdlet uploads files to a specified bucket.
    When uploading a file keep in mind that:
    
    - It must not exceed 5 billion bytes or 4.6 GB
    - It's name must be a UTF-8 string with a max size of 1000 bytes.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Invoke-B2ItemUpload -BucketID 4a48fe8875c6214145260818 -Path '.\hello.txt'
    
    Name          : hello.txt
    FileInfo      : @{author=Administrators}
    Type          : text/plain
    Length        : 38
    BucketID      : 4a48fe8875c6214145260818
    AccountID     : 30f20426f0b1
    SHA1          : E1E64A1C6E535763C5B775BAAD2ACF792D97F7DA
    ID            : 4_z4a48fe8875c6214145260818_f1073d0771c828c7f_d20160131_m052759_c001_v0001000_t0014
    
    The cmdlet above will upload the file hello.txt to the selected bucket ID and metadata about the
    uploaded file will be returned if the cmdlet is successfull.
.EXAMPLE
    PS C:\>Invoke-B2ItemUpload -BucketID 4a48fe8875c6214145260818 -Path '.\hello.txt','.\world.txt'
    
    Name          : hello.txt
    FileInfo      : @{author=Administrators}
    Type          : text/plain
    Length        : 38
    BucketID      : 4a48fe8875c6214145260818
    AccountID     : 30f20426f0b1
    SHA1          : E1E64A1C6E535763C5B775BAAD2ACF792D97F7DA
    ID            : 4_z4a48fe8875c6214145260818_f1073d0771c828c7f_d20160131_m052759_c001_v0001000_t0014
    
    Name          : world.txt
    FileInfo      : @{author=Administrators}
    Type          : text/plain
    Length        : 38
    BucketID      : 4a48fe8875c6214145260818
    AccountID     : 30f20426f0b1
    SHA1          : E1E64A1C6E535763C5B775BAAD2ACF792D97F7DA
    ID            : 4_z4a48fe8875c6214145260818_f1073d0771c828c7f_d20160131_m052759_c001_v0001000_t0014
    
    The cmdlet above will upload the files hello.txt and world.txt to the selected bucket ID.
.EXAMPLE
    PS C:\>Get-ChildItem | Invoke-B2ItemUpload -BucketID 4a48fe8875c6214145260818
    
    Name          : hello.txt
    FileInfo      : @{author=Administrators}
    Type          : text/plain
    Length        : 38
    BucketID      : 4a48fe8875c6214145260818
    AccountID     : 30f20426f0b1
    SHA1          : E1E64A1C6E535763C5B775BAAD2ACF792D97F7DA
    ID            : 4_z4a48fe8875c6214145260818_f1073d0771c828c7f_d20160131_m052759_c001_v0001000_t0014
    
    Name          : world.txt
    FileInfo      : @{author=Administrators}
    Type          : text/plain
    Length        : 38
    BucketID      : 4a48fe8875c6214145260818
    AccountID     : 30f20426f0b1
    SHA1          : E1E64A1C6E535763C5B775BAAD2ACF792D97F7DA
    ID            : 4_z4a48fe8875c6214145260818_f1073d0771c828c7f_d20160131_m052759_c001_v0001000_t0014
    
    The cmdlet above will upload all files returned by the Get-ChildItem cmdlet.
.INPUTS
    System.String
    
        This cmdlet takes the AccountID and ApplicationKey as strings.
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
    [CmdletBinding(SupportsShouldProcess=$true,
                   PositionalBinding=$true,
                   ConfirmImpact='Medium')]
    [Alias('ib2iu')]
    [OutputType('PS.B2.FileProperty')]
    Param
    (
        # The ID of the bucket to upload to.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$BucketID,
        # The file(s) to upload.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [String[]]$Path,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force
    )
    
    Begin
    {
        if($Path.Length -gt 5GB)
        {
            throw 'The file size is over the 5GB limit. Please use Invoke-B2LargeItemUpload for files of this size.'
        }
        # Pulls the unique pod upload uri for this session.
        $b2Upload = Get-B2UploadUri -BucketID $BucketID
    }
    Process
    {
        foreach($file in $Path)
        {
            if($Force -or $PSCmdlet.ShouldProcess($file, "Upload to bucket $BucketID."))
            {
                try
                {
                    # Required file info is retireved in this block and escapes HTTP data.
                    [String]$b2FileName = (Get-Item -Path $file).Name
                    $b2FileName = [System.Uri]::EscapeDataString($b2FileName)
                    # SHA1 is used as per B2 specification.
                    [String]$b2FileSHA1 = (Get-FileHash -Path $file -Algorithm SHA1).Hash
                    [String]$b2FileAuthor = (Get-Acl -Path $file).Owner
                    # Below the file author is parsed.
                    $b2FileAuthor = $b2FileAuthor.Substring($b2FileAuthor.IndexOf('\')+1)
                    # The file information is placed into the session headers.
                    [Hashtable]$sessionHeaders = @{
                        'Authorization' = $b2Upload.Token
                        'X-Bz-File-Name' = $b2FileName
                        'Content-Type' = 'b2/x-auto'
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
                        'SHA1' = $bbInfo.contentSha1
                        'FileID' = $bbInfo.fileId
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.FileProperty'
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