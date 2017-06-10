function New-B2LargeFileUpload
{
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.EXAMPLE

.INPUTS
    System.String

        This cmdlet takes the BucketID, Path, ApiUri and ApiToken as strings.

    System.Uri

        This cmdlet takes the ApiUri as a Uri.
.OUTPUTS
    PS.B2.LargeFileProperty

        This cmdlet will output a PS.B2.LargeFileProperty object holding the upload properties.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true,
                   ConfirmImpact='Medium')]
    [Alias('nb2lfu')]
    [OutputType('PS.B2.LargeFileProperty')]
    Param
    (
        # The ID of the bucket to upload to.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$BucketID,
        # The Uri for the B2 Api query.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [String[]]$Path,
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

    Begin
    {
        [Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
        [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_start_large_file"
    }
    Process
    {
        # Loops through each item in the path array and then prepares the file upload to be executed by Start-B2LargeFileUpload.
        foreach($file in $Path)
        {
            try
            {
                # Required file info is retireved in this block and escapes HTTP data.
                [String]$b2FileName = (Get-Item -Path $file).Name
                $b2FileName = [System.Uri]::EscapeDataString($b2FileName)

                [String]$sessionBody = @{'fileName'=$b2FileName;'bucketId'=$BucketID;'contentType'='b2/x-auto'} | ConvertTo-Json
                $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
                $bbReturnInfo = [PSCustomObject]@{
                    'AccountID' = $bbInfo.accountId
                    'BucketID' = $bbInfo.bucketId
                    'ContentType' = $bbInfo.contentType
                    'FileID' = $bbInfo.fileId
                    'FileInfo' = $bbInfo.fileInfo
                    'FileName' = $bbInfo.fileName
                    #Below coverts from Unix time to .NET time
                    'UploadTimestamp' = ([DateTime]'1/1/1970').AddMilliseconds($bbInfo.uploadTimestamp)
                }
                # bbReturnInfo is returned after Add-ObjectDetail is processed.
                Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.LargeFileProperty'
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