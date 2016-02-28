#needed for Unzip module
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip
{
    param([string]$Path, [string]$Destination)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $Destination)
}

#needed to find my documents folder path and current directory
$UserDocs = [System.Environment]::getfolderpath('mydocuments')

#Download the project zip
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile('https://github.com/Persistent13/PS.B2/archive/master.zip','.\PS.B2.zip')

#checks if module path exists yet and creats it if not
if(-not $(Test-Path -Path "${UserDocs}\WindowsPowerShell\Modules\PS.B2" -ErrorAction Continue))
{
    mkdir "${UserDocs}\WindowsPowerShell\Modules\PS.B2"
}

#unzips the module, places it, and cleans up
Unzip -Path .\PS.B2.zip -Destination "${UserDocs}\WindowsPowerShell\Modules\PS.B2"
Move-Item -Path "${UserDocs}\WindowsPowerShell\Modules\PS.B2\PS.B2-master\PS.B2\*" -Destination "${UserDocs}\WindowsPowerShell\Modules\PS.B2"
rm "${UserDocs}\WindowsPowerShell\Modules\PS.B2\PS.B2-master" -Recurse -Force