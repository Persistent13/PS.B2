function Remove-B2ItemVersion
{
<#
.Synopsis
	Remove-B2ItemVersion will remove the version of a given file.
	If the file only has one version the file will be deleted.
	
	An API key is required to use this cmdlet.
.DESCRIPTION
	Long description
.EXAMPLE
	Example of how to use this cmdlet
.EXAMPLE
	Another example of how to use this cmdlet
.LINK
	https://www.backblaze.com/b2/docs/
.ROLE
	PS.B2
.FUNCTIONALITY
	PS.B2
#>
	[CmdletBinding(SupportsShouldProcess=$true,
				   ConfirmImpact='High')]
	[Alias('rb2iv')]
	[OutputType('PS.B2.RemoveFile')]
	Param
	(
		# The Name of the file to delete.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String[]]$Name,
		# The ID of the file to delete.
		[Parameter(Mandatory=$true,
				   ValueFromPipeline=$true,
				   ValueFromPipelineByPropertyName=$true,
				   Position=1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[String[]]$ID,
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
        # array that conatins the file ID in the first array and thefile name in the second.
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
                        'Name' = $bbInfo.fileName
                        'ID' = $bbInfo.fileId
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