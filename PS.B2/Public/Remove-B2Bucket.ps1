function Remove-B2Bucket
{
<#
.SYNOPSIS
    Remove-B2Bucket will remove the selected bucket.
    The cmdlet will only remove a bucket if the bucket is empty.
.DESCRIPTION
    Remove-B2Bucket will remove the selected bucket.
    The cmdlet will only remove a bucket if the bucket is empty.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Remove-B2Bucket -BucketID ee7d351ff1262048503e091f
    
    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPublic  010203040506
    
    The cmdlet above will remove the bucket with the ID of ee7d351ff1262048503e091f.
.EXAMPLE
    PS C:\>Get-B2Bucket | Remove-B2Bucket -Force
    
    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPrivate 010203040506
    frisky-navigator-lion 4a48fe8875c6214145260819 allPrivate 010203040506
    
    The cmdlet above will remove all buckets associated with the account without prompting for confirmation.
.INPUTS
    System.String
    
        This cmdlet takes the AccountID and ApplicationKey as strings.
    
    System.Uri
    
        This cmdlet takes the ApiUri as a uri.
.OUTPUTS
    PS.B2.Bucket
    
        The cmdlet will output a PS.B2.Bucket object holding the bucket info.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='High')]
    [Alias('rb2b')]
    [OutputType('PS.B2.Bucket')]
    Param
    (
        # The ID of the bucket to remove.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$BucketID,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
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
        [String]$AccountID = $script:SavedB2AccountID,
        # The authorization token for the B2 account.
        [Parameter(Mandatory=$false,
                   Position=4)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$ApiToken = $script:SavedB2ApiToken
    )
    
    Begin
    {
        [Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
        [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_delete_bucket"
    }
    Process
    {
        foreach($bucket in $BucketID)
        {
            if($Force -or $PSCmdlet.ShouldProcess($bucket, "Delete bucket."))
            {
                try
                {
                    [String]$sessionBody = @{'accountId'=$AccountID;'bucketId'=$bucket} | ConvertTo-Json
                    $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
                    $bbReturnInfo = [PSCustomObject]@{
                        'BucketName' = $bbInfo.bucketName
                        'BucketID' = $bbInfo.bucketId
                        'BucketType' = $bbInfo.bucketType
                        'AccountID' = $bbInfo.accountId
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.Bucket'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Error -Exception "Unable to remove the bucket.`n`r$errorDetail" `
                        -Message "Unable to remove the bucket.`n`r$errorDetail" -Category InvalidOperation
                }
            }
        }
    }
}