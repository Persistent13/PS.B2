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
    [Alias('cdoc')]
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
        if(-not $AccountID -or -not $ApplicationKey)
        {
			if($AccountID)
			{
				[PSCredential]$bbCredential = Get-Credential -Message 'Enter your B2 account ID and application key below.' -UserName $AccountID
			}
			else
			{
				[PSCredential]$bbCredential = Get-Credential -Message 'Enter your B2 account ID and application key below.'
			}
        }
		else
		{
			[SecureString]$bbSecAppKey = ConvertTo-SecureString $ApplicationKey -AsPlainText -Force
			[PSCredential]$bbCredential = New-Object PSCredential($AccountID, $bbSecAppKey)
		}
        [Uri]$bbApiUri = 'https://api.backblaze.com/b2api/v1/b2_authorize_account'
    }
    Process
    {
        try
        {
            $bbReturnInfo = Invoke-RestMethod -Method Get -Uri $bbApiUri -Credential $bbCredential
            $script:SavedB2AccountID = $bbReturnInfo.accountId
            $script:SavedB2ApiUri = $bbReturnInfo.apiUrl
            $script:SavedB2ApiToken = $bbReturnInfo.authorizationToken
            $script:SavedB2DownloadUrl = $bbReturnInfo.downloadUrl
            Write-Output $bbReturnInfo
        }
        catch
        {
            if(Test-Connection -ComputerName $bbApiUri.DnsSafeHost -Port $bbApiUri.Port)
            {
                Write-Error -Exception 'Unable to authenticate with the given credentials.' `
                    -Message 'Unable to authenticate with given the credentials.' -Category AuthenticationError
            }
            else
            {
                Write-Error -Exception "Cannot reach $bbApiUri please check connecitvity." `
                    -Message "Cannot reach $bbApiUri please check connecitvity." -Category ConnectionError
            }
        }
    }
}