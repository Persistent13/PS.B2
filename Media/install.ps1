#This installs the PS.B2 module for the current user
#https://github.com/Persistent13/PS.B2 for more info

#needed to unzip the repo
Add-Type -AssemblyName System.IO.Compression.FileSystem

#needed to find my documents folder path and current directory
$UserDocs = [System.Environment]::getfolderpath('mydocuments')

#Download the project zip
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile('https://github.com/Persistent13/PS.B2/archive/master.zip','.\PS.B2.zip')

#checks if module path exists yet and creats it if not
if(-not $(Test-Path -Path "${UserDocs}\WindowsPowerShell\Modules\PS.B2" -ErrorAction Continue))
{
    mkdir "${UserDocs}\WindowsPowerShell\Modules\PS.B2" | Out-Null
}
else
{
    Remove-Item -Path "${UserDocs}\WindowsPowerShell\Modules\PS.B2" -Recurse -Force
}
#unzips the module, places it, and cleans up
[System.IO.Compression.ZipFile]::ExtractToDirectory('.\PS.B2.zip', "${UserDocs}\WindowsPowerShell\Modules\PS.B2")
Move-Item -Path "${UserDocs}\WindowsPowerShell\Modules\PS.B2\PS.B2-master\PS.B2\*" -Destination "${UserDocs}\WindowsPowerShell\Modules\PS.B2"
Remove-Item -Path "${UserDocs}\WindowsPowerShell\Modules\PS.B2\PS.B2-master" -Recurse -Force