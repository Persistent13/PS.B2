function Hide-B2Item
{
<#
.SYNOPSIS
    Hide-B2Item will mark a file name as hidden.
.DESCRIPTION
    Hide-B2Item will mark a file name as hidden.
    
    Hides a file so that downloading by name will not find the file,
    but previous versions of the file are still stored.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Hide-B2Item -Name items/hello.txt -BucketID 4a48fe8875c6214145260818
    
    Name       : items/hello.txt
    Size       : 0
    UploadTime : 1437815673000
    Action     : hide
    ID         : 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0104
    
    The cmdlet above will hide the latest version of the selected file in
    the selected bucket.
.EXAMPLE
    PS C:\>Get-B2Bucket | Get-B2ChildItem | Hide-B2Item
    
    Name       : items/hello.txt
    Size       : 0
    UploadTime : 1437815673000
    Action     : hide
    ID         : 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0104
    
    Name       : items/world.txt
    Size       : 0
    UploadTime : 1437815683000
    Action     : hide
    ID         : 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0105
    
    The cmdlet above will hide the latest version of the first 1000 files in all buckets.
.INPUTS
    System.String
    
        This cmdlet takes the Name, BucketID and ApiToken as strings.
    
    System.Uri
    
        This cmdlet takes the ApiUri as a uri.
.OUTPUTS
    PS.B2.File
    
        The cmdlet will output a PS.B2.File object holding upload info.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Alias('hb2f')]
    [OutputType('PS.B2.File')]
    Param
    (
        # The name of the item to hide.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        # The ID of the bucket to query.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$BucketID,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # The Uri for the B2 Api query.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Uri]$ApiUri = $script:SavedB2ApiUri,
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
        [Uri]$b2ApiUri = "$ApiUri/b2api/v1/b2_hide_file"
    }
    Process
    {
        foreach($file in $Name)
        {
            if($Force -or $PSCmdlet.ShouldProcess($file, "Hiding file in bucket $BucketID."))
            {
                try
                {
                    [String]$sessionBody = @{'bucketId'=$BucketID;'fileName'=$file} | ConvertTo-Json
                    $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
                    $bbReturnInfo = [PSCustomObject]@{
                        'Name' = $bbInfo.fileName
                        'Size' = $bbInfo.size
                        'UploadTime' = $bbInfo.uploadTimestamp
                        'Action' = $bbInfo.action
                        'ID' = $bbInfo.fileId
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.File'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Error -Exception "Unable to hide the file.`n`r$errorDetail" `
                        -Message "Unable to hide the file.`n`r$errorDetail" -Category InvalidOperation
                }
            }
        }
    }
}