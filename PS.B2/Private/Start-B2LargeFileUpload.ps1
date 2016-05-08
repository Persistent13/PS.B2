function Invoke-B2ItemUpload
{
<#
.SYNOPSIS
    
.DESCRIPTION
    
.EXAMPLE
    
.EXAMPLE
    
.EXAMPLE
    
.INPUTS
    System.String
    
        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    PS.B2.FileProperty
    
        This cmdlet will output a PS.B2.FileProperty object holding the file properties.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   PositionalBinding=$true,
                   ConfirmImpact='Medium')]
    [Alias('ib2lfu')]
    [OutputType('PS.B2.FileProperty')]
    Param
    (
        # The ID of the bucket to upload to.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$BucketID,
        # The file(s) to upload.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [String[]]$Path,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force
    )
    
    Begin
    {
        # Pulls the unique pod upload uri for this session.
        $b2Upload = Get-B2LargeFileUploadUri -BucketID $BucketID
    }
    Process
    {
        foreach($file in $Path)
        {
            if($Force -or $PSCmdlet.ShouldProcess($file, "Upload to bucket $BucketID."))
            {
                try
                {
                    # Required file info is retireved in this block and escapes HTTP data.
                    [String]$b2FileName = (Get-Item -Path $file).Name
                    $b2FileName = [System.Uri]::EscapeDataString($b2FileName)
                    # SHA1 is used as per B2 specification.
                    [String]$b2FileSHA1 = (Get-FileHash -Path $file -Algorithm SHA1).Hash
                    [String]$b2FileAuthor = (Get-Acl -Path $file).Owner
                    # Below the file author is parsed.
                    $b2FileAuthor = $b2FileAuthor.Substring($b2FileAuthor.IndexOf('\')+1)
                    # The file information is placed into the session headers.
                    [Hashtable]$sessionHeaders = @{
                        'Authorization' = $b2Upload.Token
                        'X-Bz-File-Name' = $b2FileName
                        'Content-Type' = 'b2/x-auto'
                        'X-Bz-Content-Sha1' = $b2FileSHA1
                        'X-Bz-Info-Author' = $b2FileAuthor
                    }
                    
                    $bbInfo = Invoke-RestMethod -Method Post -Uri $b2Upload.UploadUri -Headers $sessionHeaders -InFile $file
                    
                    $bbReturnInfo = [PSCustomObject]@{
                        'Name' = $bbInfo.fileName
                        'FileInfo' = $bbInfo.fileInfo
                        'Type' = $bbInfo.contentType
                        'Length' = $bbInfo.contentLength
                        'BucketID' = $bbInfo.bucketId
                        'AccountID' = $bbInfo.accountId
                        'SHA1' = $bbInfo.contentSha1
                        'ID' = $bbInfo.fileId
                    }
                    # bbReturnInfo is returned after Add-ObjectDetail is processed.
                    Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.FileProperty'
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Error -Exception "Unable to upload the file.`n`r$errorDetail" `
                        -Message "Unable to upload the file.`n`r$errorDetail" -Category InvalidOperation
                }
            }
        }
    }
}