function Invoke-B2LargeItemUpload
{
<#
.SYNOPSIS
    The Invoke-B2ItemUpload cmdlet uploads files to a specified bucket.
.DESCRIPTION
    The Invoke-B2ItemUpload cmdlet uploads files to a specified bucket.
    When uploading a file keep in mind that:

    - It must not exceed 5 GB
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
    [Alias('ib2liu')]
    [OutputType('PS.B2.LargeFileUploadComplete')]
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
        [Switch]$Force,
        # The Uri for the B2 Api query.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Uri]$ApiUri = $script:SavedB2ApiUri,
        # The authorization token for the B2 account.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$ApiToken = $script:SavedB2ApiToken
    )

    Process
    {
        foreach($file in $Path)
        {
            if($Force -or $PSCmdlet.ShouldProcess($file, "Upload to bucket $BucketID."))
            {
                try
                {
                    $newLargeItem = New-B2LargeFileUpload -BucketID $BucketID -Path $file -ApiUri $ApiUri -ApiToken $ApiToken
                    $workingLargeItem = Start-B2LargeFileUpload -FileID $newLargeItem.FileID -Path $file -ApiUri $ApiUri -ApiToken $ApiToken
                    $bbInfo = Complete-B2LargeFileUpload -FileID $newLargeItem.FileID -SHA1Array $workingLargeItem.contentSha1 -ApiUri $ApiUri -ApiToken $ApiToken
                    $bbReturnInfo = [PSCustomObject]@{
                        'AccountId' = $bbInfo.accountId
                        'Action' = $bbInfo.action
                        'BucketId' = $bbInfo.bucketId
                        'ContentLength' = $bbInfo.contentLength
                        'SHA1' = $bbInfo.contentSha1
                        'ContentType' = $bbInfo.contentType
                        'FileId' = $bbInfo.fileId
                        'FileInfo' = $bbInfo.fileInfo
                        'FileName' = $bbInfo.fileName
                        'UploadTimestamp' = $bbInfo.uploadTimestamp
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.LargeFileUploadComplete'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Error "$errorDetail"
                }
            }
        }
    }
}