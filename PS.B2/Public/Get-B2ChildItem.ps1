function Get-B2ChildItem
{
<#
.SYNOPSIS
    The Get-B2ChildItem cmdlet will return the item list of a bucket and associated file properties.
.DESCRIPTION
    The Get-B2ChildItem cmdlet will return the item list of a bucket and associated file properties.
    
    The file information to be returned:
    
    - Name
    - Size
    - UploadTime
    - Action
    - ID
    
    By default the selection has a hard limit to the first 1000 items; to increment the selection
    use the StartName paramter to specifiy the next starting item's name and ItemCount to set the 
    list limit from the file in StartName.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Get-B2ChildItem -BucketID 4a48fe8875c6214145260818
    
    Name       : items/hello.txt
    Size       : 6
    UploadTime : 1439083733000
    Action     : upload
    ID         : 4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6b_d20150809_m012853_c100_v0009990_t0000
    
    Name       : items/world.txt
    Size       : 6
    UploadTime : 1439083734000
    Action     : upload
    ID         : 4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6c_d20150809_m012854_c100_v0009990_t0000
    
    The cmdlet above will list all items in the given bucket upto the first 1000.
.EXAMPLE
    PS C:\>Get-B2ChildItem -BucketID 4a48fe8875c6214145260818 -StartName items/world.txt -ItemCount 3
    
    Name       : items/world.txt
    Size       : 6
    UploadTime : 1439083734000
    Action     : upload
    ID         : 4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6c_d20150809_m012854_c100_v0009990_t0000
    
    Name       : items/how.txt
    Size       : 6
    UploadTime : 1439083734000
    Action     : upload
    ID         : 4_z27c88f1d182b150646ff0b16_f8aa4ba650fe24e6c_d20150809_m012854_c100_v0009990_t0000
    
    Name       : items/are.txt
    Size       : 6
    UploadTime : 1439083734000
    Action     : upload
    ID         : 4_z27c88f1d182b150646ff0b16_f1004hf950fe24e6c_d20150809_m012854_c100_v0009990_t0000
    
    The cmdlet above will start listing the items from items/world.txt and then three preceeding
    items after that.
.LINK
    https://www.backblaze.com/b2/docs/
.OUTPUTS
    PS.B2.File
    
        The cmdlet will output a PS.B2.File object holding file version info.
.ROLE
    PS.B2
.FUNCTIONALITY
    The Get-B2ChildItem cmdlet will list files contained in the selected bucket.
#>
    [CmdletBinding(SupportsShouldProcess=$false)]
    [Alias('gb2ci')]
    [OutputType('PS.B2.File')]
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
        # The name of the item to start listing from.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$StartName,
        # The number of items to return; the default and max is 1000.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt32]$ItemCount = 1000,
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
        [Uri]$b2ApiUri = "${ApiUri}b2api/v1/b2_list_file_names"
        Write-Debug $b2ApiUri
    }
    Process
    {
        foreach($bucket in $BucketID)
        {
            try
            {
                [String]$sessionBody = @{'bucketId'=$bucket;'maxFileCount'=$ItemCount;'startFileName'=$StartName} | ConvertTo-Json
                $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
                foreach($info in $bbInfo.files)
                {
                    $bbReturnInfo = [PSCustomObject]@{
                        'Name' = $info.fileName
                        'Size' = $info.size
                        'UploadTime' = $info.uploadTimestamp
                        'Action' = $info.action
                        'ID' = $info.fileId
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.File'
                }
            }
            catch
            {
                $errorDetail = $_.Exception.Message
                Write-Error -Exception "Unable to retrieve the item list.`n`r$errorDetail" `
                    -Message "Unable to retrieve the item list.`n`r$errorDetail" -Category ReadError
            }
        }
    }
}