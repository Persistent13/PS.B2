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
        $item = Get-Item -Path $Path
        $stream = [System.IO.File]::OpenRead($item.FullName)
        $buffer = [Byte[]]::New($ChunkSize)
        [UInt32]$i = 1 # A number from 1 to 10000, must always start with 1.
        $bbReturnInfo = @()
        # Due to Invoke-RestMethod's poor performace in cleaning up stale connections
        # we have to break HTTP 1.1 spec and allow for a greater than 2 simultaneous connections
        # by setting the connection limit to 4. This change only effects this script's scope.
        #$ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($bbLargeUploadUri.UploadUri)
        #$ServicePoint.ConnectionLimit = 8
    }
    Process
    {
        try
        {
            $fileInfo = [System.IO.FileInfo]::New($Path)
            $localFileize = $fileInfo.Length
            $totalBytesSent = 0
            $bytesSentForPart=100000000
            $minPartSize=$bytesSentForPart
            $arr=[System.Collections.ArrayList]::New()
            [byte[]]$data=[byte]::new(100000000)
            while($bytesRead = $stream.Read($buffer,0,$ChunkSize))
            {
                # Set file
                $tmpFile = '{0}.{1}.{2}' -f $item.Name,$i,'tmp'
                $tmpPath = "$env:TEMP\$tmpFile"
                $openStream = [System.IO.File]::OpenWrite($tmpPath)
                $openStream.Write($buffer,0,$bytesRead)
                $openStream.Close()
                [String]$hash = (Get-FileHash -Path $tmpPath -Algorithm SHA1).Hash
                [Uint32]$length = ([System.IO.FileInfo]$tmpPath).Length

                # Set webclient
                $webClient = [System.Net.WebClient]::New()
                $webClient.Headers.Add('Authorization', $bbLargeUploadUri.Token)
                $webClient.Headers.Add('X-Bz-Part-Number', $i)
                $webClient.Headers.Add('X-Bz-Content-Sha1', $hash)
                $webClient.Headers.Add('Content-Length', $length)
                $webClient.Headers.Add('ContentType','multipart/form-data')

                # Do
                [Byte[]]$res = $webClient.UploadFile($bbLargeUploadUri.UploadUri, 'Post', $tmpPath)
                [String]$resText = [System.Text.Encoding]::ASCII.GetString($res)
                $bbReturnInfo += $resText | ConvertFrom-Json
                <#
                [Hashtable]$sessionHeaders = @{
                            'Authorization' = $bbLargeUploadUri.Token
                            'X-Bz-Part-Number' = $i
                            'X-Bz-Content-Sha1' = (Get-FileHash -Path $tmpPath -Algorithm SHA1).Hash
                            'Content-Length' = ([System.IO.FileInfo]$tmpPath).Length
                }
                $bbReturnInfo += Invoke-RestMethod -Method Post -Uri $bbLargeUploadUri.UploadUri -Headers $sessionHeaders -InFile $tmpPath -DisableKeepAlive
                #>
                Remove-Item -Path $tmpPath -Force
                $i++
            }
        }
        catch
        {
            $stream.Close()
            $openStream.Close()
            Remove-Item -Path $tmpPath -Force
            $errorDetail = $_.Exception.Message
            Write-Error -Message "$errorDetail"
        }
    }
    End
    {
        $stream.Close()
        Write-Output $bbReturnInfo
    }
}