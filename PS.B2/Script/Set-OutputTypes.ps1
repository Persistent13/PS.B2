if(-not $(Get-TypeData -TypeName 'PS.B2.*'))
{
    #Used to import the mime type finder in Set-B2BlobContent
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

    #Adds blob OutputType
    $blob = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.Blob'
        Value = $null
    }
    
    Update-TypeData @blob -MemberName Action
    Update-TypeData @blob -MemberName FileID
    Update-TypeData @blob -MemberName FileName
    Update-TypeData @blob -MemberName Size
    Update-TypeData @blob -MemberName UploadTime

    #Adds blobProperty OutputType
    $blobProperty = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.BlobProperty'
        Value = $null
    }
    
    Update-TypeData @blobProperty -MemberName AccountID
    Update-TypeData @blobProperty -MemberName BucketID
    Update-TypeData @blobProperty -MemberName ContentLength
    Update-TypeData @blobProperty -MemberName ContentSHA1
    Update-TypeData @blobProperty -MemberName ContentType
    Update-TypeData @blobProperty -MemberName FileID
    Update-TypeData @blobProperty -MemberName FileInfo
    Update-TypeData @blobProperty -MemberName FileName

    #Adds uploadUri OutputType
    $uploadUri = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.UploadUri'
        Value = $null
    }

    Update-TypeData @uploadUri -MemberName BucketID
    Update-TypeData @uploadUri -MemberName UploadUri
    Update-TypeData @uploadUri -MemberName Token

    #Adds removeBlob OutputType
    $removeBlob = @{
        MemberType = 'NoteProperty'
        TypeName = 'PS.B2.RemoveBlob'
        Value = $null
    }

    Update-TypeData @removeBlob -MemberName FileID
    Update-TypeData @removeBlob -MemberName FileName
}