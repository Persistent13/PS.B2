if(-not $(Get-TypeData -TypeName 'PS.B2.*'))
{
    #Adds account OutputType
    $account = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.Account'
        Value = $null
    }
    
    Update-TypeData @account -MemberName AccountID
    Update-TypeData @account -MemberName ApiUri
    Update-TypeData @account -MemberName DownloadUri
    Update-TypeData @account -MemberName Token
    
    #Adds bucket OutputType
    $bucket = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.Account'
        Value = $null
    }
    
    Update-TypeData @account -MemberName BucketName
    Update-TypeData @account -MemberName BucketID
    Update-TypeData @account -MemberName BucketType
    Update-TypeData @account -MemberName AccountID
}