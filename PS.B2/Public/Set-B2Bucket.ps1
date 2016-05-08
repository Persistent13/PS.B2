function Set-B2Bucket
{
<#
.SYNOPSIS
    Set-B2Bucket allows you to change the bucket type.
.DESCRIPTION
    Set-B2Bucket allows you to change the bucket type.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Set-B2Bucket -BucketID 4a48fe8875c6214145260818 -BucketType allPublic
    
    BucketName         BucketID                 BucketType AccountID
    ----------         --------                 ---------- ---------
    slack-jimmy-carrot 4a48fe8875c6214145260818 allPublic  30f20426f0b1
    
    The cmdlet above will set the bucket with the ID 4a48fe8875c6214145260818 to allPublic.
.EXAMPLE
    PS C:\>Get-B2Bucket | Where-Object {$_.BucketType -eq allPrivate} | Set-B2Bucket -BucketType allPublic
    
    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPublic  010203040506
    frisky-navigator-lion 4a48fe8875c6214145260819 allPublic  010203040506
    
    The cmdlets above will set all, if any, allPrivate buckets to allPublic.
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
                   PositionalBinding=$true,
                   ConfirmImpact='High')]
    [Alias('sb2b')]
    [OutputType('PS.B2.Bucket')]
    Param
    (
        # The ID of the bucket to update.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1,50)]
        [String[]]$BucketID,
        # What type of bucket, public or private, to create.
        [Parameter(Mandatory=$true)]
        [ValidateSet('allPublic','allPrivate')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$BucketType,
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
        [String]$AccountID = $script:SavedB2AccountID,
        # The authorization token for the B2 account.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$ApiToken = $script:SavedB2ApiToken
    )
    
    Begin
    {
        [Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
        [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_update_bucket"
    }
    Process
    {
        foreach($bucket in $BucketID)
        {
            if($Force -or $PSCmdlet.ShouldProcess($bucket, "Set bucket type to $BucketType."))
            {
                try
                {
                    [String]$sessionBody = @{'accountId'=$AccountID;'bucketId'=$bucket;'bucketType'=$BucketType} | ConvertTo-Json
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
                    Write-Error -Exception "Unable to make the bucket change.`n`r$errorDetail" `
                        -Message "Unable to make the bucket change.`n`r$errorDetail" -Category InvalidOperation
                }
            }
        }
    }
}