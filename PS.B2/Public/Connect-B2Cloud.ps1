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
   
    AccountID       ApiUri                       DownloadUri                Token
    ---------       ------                       -----------                -----
    30f20426f0b1    https://api900.backblaze.com https://f900.backblaze.com YOUR_TOKEN

    The above command will prompt for the account ID and application key and save it for use in other PS.B2 modules.
    The API uri, download uri, and authorization token will be returned if the cmdlet was successful.

.EXAMPLE
    PS C:\>Connect-B2Cloud -AccountID 30f20426f0b1 -ApplicationKey YOUR_APPLICATION_KEY
   
    AccountID       ApiUri                       DownloadUri                Token
    ---------       ------                       -----------                -----
    30f20426f0b1    https://api900.backblaze.com https://f900.backblaze.com YOUR_TOKEN

    The above command will take the account ID and application key given and save it for use in other PS.B2 modules.
    The API uri, download uri, and authorization token will be returned if the cmdlet was successful.

.INPUTS
    System.String

        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    PS.B2.Account

        The cmdlet will output a PS.B2.Account object holding account authorization info.
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
            if(-not $AccountID -or -not $ApplicationKey)
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