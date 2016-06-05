function Complete-B2LargeFileUpload
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
    [CmdletBinding(SupportsShouldProcess=$false, 
                   PositionalBinding=$true)]
    [Alias()]
    [OutputType('PS.B2.LargeFileUploadComplete')]
    Param
    (
        # The ID for the uploaded file.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$FileID,
        # An array of hashes of the uploaded parts.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$SHA1Array,
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
        [String]$sessionBody = @{'partSha1Array'=$SHA1Array;'fileId'=$FileID}
        [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_finish_large_file"
    }
    Process
    {
        try
        {
            $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
            $bbReturnInfo = [PSCustomObject]@{
                'AccountID' = $bbInfo.accountId
                'Action' = $bbInfo.action
                'BucketID' = $bbInfo.bucketId
                'ContentLength' = $bbInfo.contentLength
                'SHA1' = $bbInfo.contentSha1
                'ContentType' = $bbInfo.contentType
                'FileID' = $bbInfo.fileId
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
            Write-Error -Exception "Unable to complete the file upload.`n`r$errorDetail" `
                -Message "Unable to complete the file upload.`n`r$errorDetail" -Category InvalidOperation
        }
    }
}