function New-B2Bucket
{
<#
.SYNOPSIS
    New-B2Bucket will create a new private or public bucket and requires a globally unique name.
.DESCRIPTION
    New-B2Bucket will create a new private or public bucket and requires a globally unique name.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    New-B2Bucket -BucketName stoic-barbarian-lemur -BucketType allPublic
    
    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPublic  010203040506
    
    The cmdlet above will create a public bucket with the name of stoic-barbarian-lemur.
.EXAMPLE
    PS C:\>New-B2Bucket -BucketName stoic-barbarian-lemur, frisky-navigator-lion -BucketType allPrivate
    
    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPrivate 010203040506
    frisky-navigator-lion 4a48fe8875c6214145260819 allPrivate 010203040506
    
    The cmdlet above will create a public bucket with the name of stoic-barbarian-lemur and frisky-navigator-lion.
.INPUTS
    System.String
    
        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    PS.B2.Bucket
    
        The cmdlet will output a PS.B2.Bucket object holding the bucket info.
    
    System.Uri
    
        This cmdlet takes the ApiUri as a uri.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   PositionalBinding=$true,
                   ConfirmImpact='Low')]
    [Alias('nb2b')]
    [OutputType('PS.B2.Bucket')]
    Param
    (
        # The name of the new B2 bucket.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1,50)]
        [String[]]$BucketName,
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
    }
    Process
    {
        foreach($bucket in $BucketName)
        {
            if($Force -or $PSCmdlet.ShouldProcess($bucket, "Creating new $BucketType bucket."))
            {
                try
                {
                    [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_create_bucket?accountId=$AccountID&bucketName=$bucket&bucketType=$BucketType"
                    $bbInfo = Invoke-RestMethod -Method Get -Uri $b2ApiUri -Headers $sessionHeaders
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
                    Write-Error -Exception "Unable to create the new bucket.`n`r$errorDetail" `
                        -Message "Unable to create the new bucket.`n`r$errorDetail" -Category InvalidOperation
                }
            }
        }
    }
}