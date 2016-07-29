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
        [System.IO.FileInfo]$Path,
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
        $stream = [System.IO.File]::OpenRead($Path.FullName)
        $buffer = [Byte[]]::New($ChunkSize)
        [UInt32]$i = 0
        $bbReturnInfo = @()
    }
    Process
    {
        try
        {
            while($bytesRead = $stream.Read($buffer,0,$ChunkSize))
            {
                $tmpFile = '{0}.{1}.{2}' -f $Path.Name,$i,'tmp'
                $tmpPath = "$env:TEMP\$tmpFile"
                $openStream = [System.IO.File]::OpenWrite($tmpPath)
                $openStream.Write($buffer,0,$bytesRead)
                $openStream.Close()
                [Hashtable]$sessionHeaders = @{
                            'Authorization' = $bbLargeUploadUri.Token
                            'X-Bz-Part-Number' = $i
                            'X-Bz-Content-Sha1' = (Get-FileHash -Path $tmpPath -Algorithm SHA1).Hash
                            'Content-Length' = ([System.IO.FileInfo]$tmpPath).Length
                }
                $bbReturnInfo += Invoke-RestMethod -Method Post -Uri $bbLargeUploadUri.UploadUri -Headers $sessionHeaders -InFile $tmpPath
                Remove-Item -Path $tmpPath -Force
                [GC]::Collect()
                $i++
            }
        }
        finally
        {
            $openStream.Close()
            Remove-Item -Path $tmpPath -Force
            $errorDetail = $_.Exception.Message
            Write-Error -Message "$errorDetail"
            [GC]::Collect()
        }
    }
    End
    {
        Write-Output -InputObject $bbReturnInfo
    }
}