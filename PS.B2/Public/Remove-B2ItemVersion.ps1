function Remove-B2ItemVersion
{
<#
.SYNOPSIS
    Remove-B2ItemVersion will remove the version of a given file.
    If the file only has one version the file will be deleted.
.DESCRIPTION
    Remove-B2ItemVersion will remove the version of a given file.
    If the file only has one version the file will be deleted.
    
    If the version you delete is the latest version, and there are older versions, then the most recent older version will become the
    current version, and be the one that you'll get when downloading by name.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Remove-B2ItemVersion -Name items/hello.txt -ID 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0104
    
    Name            ID
    ----            --
    typing_test.txt 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0109
    
    The cmdlet above will 
.EXAMPLE
    PS C:\>Get-B2Bucket | Get-B2ChildItem | Remove-B2ItemVersion -Force
    
    Name            ID
    ----            --
    items/hello.txt 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0104
    items/world.txt 4_h4a48fe8875c6214145260818_f000000000000472a_d20140104_m032022_c001_v0000123_t0105
    
    The cmdlet above will remove the latest version of the first 1000 files in all buckets without prompting.
    If the file has only one version the file will be deleted.
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
    [Alias('rb2iv')]
    [OutputType('PS.B2.RemoveFile')]
    Param
    (
        # The Name of the file to delete.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        # The ID of the file to delete.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]$ID,
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
    
    Begin
    {
        # The Begin block verifies each item Name is paired with an item ID, builds the session
        # headers, and the API URI.
        if($ID.Count -ne $Name.Count)
        {
            throw 'A file ID must be accompanied by its file name.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'=$ApiToken}
        [Array[]]$b2FileArray = @(), @()
        [Uri]$b2ApiUri = "${ApiUri}b2api/v1/b2_delete_file_version"
    }
    Process
    {
        # Due to how PowerShell handles pushing objects over the pipline deletion of the files
        # takes place in the End code block after all the objects in the pipeline have been
        # added to the $b2FileArray variable.
        try
        {
            foreach($id in $ID)
            {
                $b2FileArray[0] += $id
            }
            foreach($name in $FileName)
            {
                $b2FileArray[1] += $name
            }
        }
        catch
        {
            # This shouldn't ever happen but just in case. 
            throw 'Unable to create the file ID and file name arrays.'
        }
    }
    End
    {
        # The End block will start the removal of the given files by looping through a multidimensional
        # array that conatins the file ID in array 0 and the file name in array 1.
        for($i = 0; $i -lt $b2FileArray[0].Count; $i++)
        {
            if($Force -or $PSCmdlet.ShouldProcess($b2FileArray[1][$i],"Remove file version $($b2FileArray[0][$i])."))
            {
                try
                {
                    # Converts the slected file ID and name to a JSON string that will be POST'd.
                    [String]$sessionBody = @{'fileId'=$b2FileArray[0][$i];'fileName'=$b2FileArray[1][$i]} | ConvertTo-Json
                    $bbInfo = Invoke-RestMethod -Method Post -Uri $b2ApiUri -Headers $sessionHeaders -Body $sessionBody
                    $bbReturnInfo = [PSCustomObject]@{
                        'FileName' = $bbInfo.fileName
                        'FileID' = $bbInfo.fileId
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.RemoveFile'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Error -Exception "Unable to delete the file version.`n`r$errorDetail" `
                        -Message "Unable to delete the file version.`n`r$errorDetail" -Category ObjectNotFound
                }
            }
        }
    }
}