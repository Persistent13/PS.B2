if(-not $(Get-TypeData -TypeName 'PS.B2.*'))
{
    #Used to import the mime type finder in Invoke-B2ItemUpload
    Add-Type -AssemblyName System.Web

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

    #Adds file OutputType
    $file = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.File'
        Value = $null
    }
    
    Update-TypeData @file -MemberName Action
    Update-TypeData @file -MemberName ID
    Update-TypeData @file -MemberName Name
    Update-TypeData @file -MemberName Size
    Update-TypeData @file -MemberName UploadTime

    #Adds fileProperty OutputType
    $fileProperty = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.FileProperty'
        Value = $null
    }
    
    Update-TypeData @fileProperty -MemberName AccountID
    Update-TypeData @fileProperty -MemberName BucketID
    Update-TypeData @fileProperty -MemberName Length
    Update-TypeData @fileProperty -MemberName SHA1
    Update-TypeData @fileProperty -MemberName Type
    Update-TypeData @fileProperty -MemberName ID
    Update-TypeData @fileProperty -MemberName FileInfo
    Update-TypeData @fileProperty -MemberName Name

    #Adds uploadUri OutputType
    $uploadUri = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.UploadUri'
        Value = $null
    }

    Update-TypeData @uploadUri -MemberName BucketID
    Update-TypeData @uploadUri -MemberName UploadUri
    Update-TypeData @uploadUri -MemberName Token

    #Adds removeFile OutputType
    $removeFile = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.RemoveFile'
        Value = $null
    }

    Update-TypeData @removeFile -MemberName ID
    Update-TypeData @removeFile -MemberName Name
}