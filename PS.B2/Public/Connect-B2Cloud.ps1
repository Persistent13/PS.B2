function Connect-B2Cloud
{
<#
.SYNOPSIS
    The Connect-B2Cloud cmdlet sets the API key for the Backblaze B2 module cmdlets.
.DESCRIPTION
    The Connect-B2Cloud cmdlet is used to retireve the API Uri, download Uri, and API
    token that authorizes actions againt a B2 account. The cmdlet returns the results
    of the REST query as text if successful and an error if not successful.

    The application key and account ID can be obtained from your Backblaze B2 account page.
.EXAMPLE
    Connect-B2Cloud

    AccountID       ApiUri                       DownloadUri                Token
    ---------       ------                       -----------                -----
    30f20426f0b1    https://api900.backblaze.com https://f900.backblaze.com YOUR_TOKEN

    The above cmdlet will prompt for the account ID and application key, authenticate, and
    save the token, API Uri, and download Uri returned for use in the other PS.B2 modules.

    The API Uri, download Uri, and authorization token will be returned if the cmdlet was successful.
.EXAMPLE
    PS C:\>Connect-B2Cloud -AccountID 30f20426f0b1 -ApplicationKey YOUR_APPLICATION_KEY

    AccountID       ApiUri                       DownloadUri                Token
    ---------       ------                       -----------                -----
    30f20426f0b1    https://api900.backblaze.com https://f900.backblaze.com YOUR_TOKEN

    The above cmdlet will take the given account ID and application key authenticate and
    save the token, API Uri, and download Uri returned for use in the other PS.B2 modules.

    The API Uri, download Uri, and authorization token will be returned if the cmdlet was successful.
.INPUTS
    System.String

        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    PS.B2.Account

        The cmdlet will output a PS.B2.Account object holding account authorization info.
.NOTES
    Connect-B2Cloud will always output the account information on a successful connection, to
    prevent this it is recommened to pipe the out put to Out-Null. i.e. Connect-B2Cloud | Out-Null
.LINK
    https://www.backblaze.com/b2/docs/
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
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [String]$AccountID,
        # The application key to access the B2 account.
        [Parameter(Mandatory=$false)]
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
            try
            {
                [String]$AccountID = $b2Creds.GetNetworkCredential().UserName
                [String]$ApplicationKey = $b2Creds.GetNetworkCredential().Password
            }
            catch
            {
                throw 'You must specify the account ID and application key.'
            }
        }
        # Invoke-RestMethod cannot be used with the -Crednetial paramter.
        # B2 authentication breaks RFC2617 and the authroization header must be crafted manually.
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
            [String]$script:SavedB2AccountID = $bbInfo.accountId
            [Uri]$script:SavedB2ApiUri = $bbInfo.apiUrl
            [String]$script:SavedB2ApiToken = $bbInfo.authorizationToken
            [Uri]$script:SavedB2DownloadUri = $bbInfo.downloadUrl
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