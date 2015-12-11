function Connect-B2Cloud
{
<#
.Synopsis
   The Connect-B2Cloud cmdlet sets the API key for the Backblaze B2 module cmdlets.
.DESCRIPTION
   The Connect-B2Cloud cmdlet sets the API key for the Backblaze B2 module cmdlets.
   The application key and account ID can be obtained from your Backblaze B2 account page.

   An API key is required to use this cmdlet.
.EXAMPLE
   Connect-B2Cloud

   The above command will prompt for the account ID and application key and save it for use in other PS.B2 modules.

.EXAMPLE
   PS C:\>Connect-B2Cloud -AccountID YOUR_ACCOUNT_ID -ApplicationKey YOUR_APPLICATION_KEY

   The above command will take the account ID and application key given and save it for use in other PS.B2 modules.

.INPUTS
   System.String
        
       This cmdlet can take the API key as a string.
.OUTPUTS
   None
.ROLE
   PS.B2
.FUNCTIONALITY
   PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding=$true)]
    [Alias('cb2c')]
    [OutputType('PS.B2.Account')]
    Param
    (
        # The account ID for the B2 account.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [String]$AccountID,
        # The application key to access the B2 account.
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key')]
        [String]$ApplicationKey
    )

    Begin
    {
        if(-not $AccountID -or -not $ApplicationKey)
        {
            [PSCredential]$b2Creds = Get-Credential -Message 'Enter your B2 account ID and application key below.'
            [String]$AccountID = $b2Creds.GetNetworkCredential().UserName
            [String]$ApplicationKey = $b2Creds.GetNetworkCredential().Password
        }
        [String]$plainCreds = "${AccountID}:${ApplicationKey}"
        [String]$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($plainCreds))
        [Hashtable]$sessionHeaders = @{'Authorization'="Basic $encodedCreds"}
        [Uri]$bbApiUri = 'https://api.backblaze.com/b2api/v1/b2_authorize_account'
    }
    Process
    {
        try
        {
            $bbInfo = Invoke-RestMethod -Method Get -Uri $bbApiUri -Headers $sessionHeaders
            $script:SavedB2AccountID = $bbInfo.accountId
            $script:SavedB2ApiUri = $bbInfo.apiUrl
            $script:SavedB2ApiToken = $bbInfo.authorizationToken
            $script:SavedB2DownloadUri = $bbInfo.downloadUrl
            $bbReturnInfo = [PSCustomObject]@{
                'AccountID' = $bbInfo.accountId
                'ApiUri' = $bbInfo.apiUrl
                'DownloadUri' = $bbInfo.downloadUrl
                'Token' = $bbInfo.authorizationToken
            }
			# bbReturnInfo is returned after Add-ObjectDetail is processed.
			Add-ObjectDetail -InputObject $bbReturnInfo -TypeName 'PS.B2.Account'
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            Write-Error -Exception "Unable to authenticate with given APIKey.`n`r$errorDetail" `
                -Message "Unable to authenticate with given APIKey.`n`r$errorDetail" -Category AuthenticationError
        }
    }
}