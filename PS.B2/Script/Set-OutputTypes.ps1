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
        TypeName = 'PS.B2.Bucket'
        Value = $null
    }
    
    Update-TypeData @bucket -MemberName BucketName
    Update-TypeData @bucket -MemberName BucketID
    Update-TypeData @bucket -MemberName BucketType
    Update-TypeData @bucket -MemberName AccountID
}