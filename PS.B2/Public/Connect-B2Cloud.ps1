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
    [OutputType()]
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
        if(-not $AccountID)
        {
            [String]$AccountID = (Get-Credential -Message 'Enter your B2 account ID and application key below.' -UserName 'AccountID').GetNetworkCredential().Password
        }
        if(-not $ApplicationKey)
        {
            [String]$ApplicationKey = (Get-Credential -Message 'Enter your B2 account ID and application key below.' -UserName 'ApplicationKey').GetNetworkCredential().Password
        }
        [Hashtable]$sessionHeaders = @{$AccountID=$ApplicationKey;'Content-Type'='application/json'}
        [Uri]$bbApiUri = 'https://api.backblaze.com/b2api/v1/b2_authorize_account'
    }
    Process
    {
        try
        {
            $bbReturnInfo = Invoke-RestMethod -Method Get -Uri $bbApiUri -Headers $sessionHeaders
            $script:SavedB2AccountID = $bbReturnInfo.accountId
            $script:SavedB2ApiUri = $bbReturnInfo.apiUrl
            $script:SavedB2ApiToken = $bbReturnInfo.authorizationToken
            $script:SavedB2DownloadUrl = $bbReturnInfo.downloadUrl
            Write-Output $bbReturnInfo
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            Write-Error -Exception "Unable to authenticate with given APIKey.`n`r$errorDetail" `
                -Message "Unable to authenticate with given APIKey.`n`r$errorDetail" -Category AuthenticationError
        }
    }
}