function Start-B2LargeFileUpload
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
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true)]
    [Alias()]
    [OutputType()]
    Param
    (
        # The file to upload.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        # The ID of the file to upload.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$FileID,
        # Sets the size of the file chunks.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(100MB,5GB)]
        [UInt64]$ChunkSize = 100MB,
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
        try
        {
            $bbLargeUploadUri = Get-B2LargeFileUploadUri -FileID $FileID -ApiUri $ApiUri -ApiToken $ApiToken
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            throw "Unable to connect to the B2 cloud: $errorDetail"
        }
        $fileIO = [IO.File]::OpenRead($Path)
        $buffer = [Byte[]]::New($ChunkSize)
        [UInt32]$count = [UInt32]$i = 0
        $bbReturnInfo = @()
    }
    Process
    {
        try
        {
            do
            {
                $count = $fileIO.Read($buffer,0,$buffer.Length)
                if($count -gt 0)
                {
                    $to = '{0}.{1}.{2}' -f $Path,$i,'tmp'
                    $toFile = [IO.File]::OpenWrite($to)
                    try
                    {
                        $toFile.Write($buffer,0,$count)
                        $toFile.Close()
                        [Hashtable]$sessionHeaders = @{
                            'Authorization' = $bbLargeUploadUri.Token
                            'X-Bz-Part-Number' = $i
                            'X-Bz-Content-Sha1' = (Get-FileHash -Path $to -Algorithm SHA1).Hash
                            'Content-Length' = $to.Length
                        }
                        $bbReturnInfo += Invoke-RestMethod -Method Post -Uri $bbLargeUploadUri.UploadUri -Headers $sessionHeaders -InFile $to
                        Remove-Item -Path $to -Force
                    }
                    finally
                    {
                        $toFile.Close()
                        Remove-Item -Path $to -Force
                        $errorDetail = $_.Exception.Message
                        Write-Error -Message "Unable to split the file into parts: $errorDetail"
                    }
                }
                $i++
            }
            while($count -gt 0)
        }
        finally
        {
            $fileIO.Close()
            Remove-Item -Path $to -Force
            $errorDetail = $_.Exception.Message
            Write-Error -Message "Unable to split the file into parts: $errorDetail"
        }
    }
    End
    {
        Write-Output -InputObject $bbReturnInfo
    }
}