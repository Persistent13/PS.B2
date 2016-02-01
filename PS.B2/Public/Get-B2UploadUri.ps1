function Get-B2UploadUri
{
<#
.Synopsis
    Get-B2UploadUri will get the upload uri for a given bucket. 
.DESCRIPTION
    Get-B2UploadUri will get the upload uri for a given bucket.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Get-B2UploadUri -BucketID 4a48fe8875c6214145260818
    
    BucketID                 UploadUri
    --------                 ---------
    4ebdd57f81669028501e091f https://pod-000-1015-16.backblaze.com/b2api/v1/b2_upload_file/4ebdd57f81669028501e091f/c001...
    
    The cmdlet above will return the upload uri for the bucket with ID 4ebdd57f81669028501e091f.
.EXAMPLE
    PS C:\>Get-B2Bucket | Get-B2UploadUri
    
    BucketID                 UploadUri
    --------                 ---------
    4ebdd57f81669028501e091f https://pod-000-1015-16.backblaze.com/b2api/v1/b2_upload_file/4ebdd57f81669028501e091f/c001...
    4a48fe8875c6214145260818 https://pod-000-1005-03.backblaze.com/b2api/v1/b2_upload_file?cvt=c001_v0001005_t0027&bucke...
    
    The cmdlet above will return the upload uri for all buckets available for the account.
.INPUTS
    System.String
    
        This cmdlet takes the BucketID and ApiToken as strings.
    
    System.Uri
    
        This cmdlet takes the ApiUri as a uri.
.OUTPUTS
    PS.B2.UploadUri
    
        The cmdlet will output a PS.B2.UploadUri object holding upload info.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(PositionalBinding=$false)]
    [Alias()]
    [OutputType('PS.B2.UploadUri')]
    Param
    (
        # The ID of the bucket to query.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$BucketID,
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
        [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_get_upload_url"
    }
    Process
    {
        foreach($bucket in $BucketID)
        {
            try
            {
                [String]$sessionBody = @{'bucketId'=$bucket} | ConvertTo-Json
                $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
                $bbReturnInfo = [PSCustomObject]@{
                    'BucketID' = $bbInfo.bucketId
                    'UploadUri' = $bbInfo.uploadUrl
                    'Token' = $bbInfo.authorizationToken
                }
                # bbReturnInfo is returned after Add-ObjectDetail is processed.
                Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.UploadUri'
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Error -Exception "Unable to retrieve the upload uri.`n`r$errorDetail" `
                    -Message "Unable to retrieve the upload uri.`n`r$errorDetail" -Category ReadError
            }
        }
    }
}