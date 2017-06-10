# Remove the module and then import the module
$WorkspaceRoot = $(Get-Item $PSScriptRoot).Parent.FullName
Remove-Module 'PS.B2' -ErrorAction Ignore
Import-Module "$WorkspaceRoot\PS.B2\PS.B2.psd1" -Force

InModuleScope PS.B2 {
    $b2_account = @{
        # Tests will inherit AccountID parameter from accountId
        'accountId' = '30f20426f0b1'
        # Tests will inherit ApiUri parameter from apiUrl
        'apiUrl' = 'https://api001.backblazeb2.com'
        # Tests will inherit Token parameter from authorizationToken
        'authorizationToken' = '2_20150807002553_443e98bf57f978fa58c284f8_24d25d99772e3ba927778b39c9b0198f412d2163_acct'
        'downloadUrl' = 'https://f700.backblazeb2.com'
        'recommendedPartSize' = 100000000
        'absoluteMinimumPartSize' = 250000
    }
    $b2_buckets = @{
        # When new BucketTypes are added include them here
        # Should always match the same number for the Action enum
        'buckets' = @{
            'accountId' = '30f20426f0b1'
            'bucketId' = '4a48fe8875c6214145260818'
            'bucketInfo' = @{}
            'bucketName' = 'FooBar'
            'bucketType' = [PSB2.BucketType]::allPrivate
            'lifecycleRules' = @()
            'revision' = 20
        },
        @{
            'accountId' = '30f20426f0b1'
            'bucketId' = '4a48fe8875c6214145260819'
            'bucketInfo' = @{}
            'bucketName' = 'FooBazz'
            'bucketType' = [PSB2.BucketType]::allPublic
            'lifecycleRules' = @()
            'revision' = 1
        },
        @{
            'accountId' = '30f20426f0b1'
            'bucketId' = '4a48fe8875c6214145260821'
            'bucketInfo' = @{}
            'bucketName' = 'ZooBazz'
            'bucketType' = [PSB2.BucketType]::snapshot
            'lifecycleRules' = @()
            'revision' = 23
        }
    }
    $b2_item = @{
        'files' = @{
                'action' = 'upload'
                'contentLength' = 6
                'contentType' = 'text/plain'
                'contentSha1' = 'EB40BC89583313F3A07BC44BF0AA1FF1100C5DB507C853F6D1037B12654EBBFB'
                'fileInfo' = @{}
                'fileId' = '4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6b_d20150809_m012853_c100_v0009990_t0000'
                'fileName' = 'files/hello.txt'
                'uploadTimestamp' = 1439083733000
            },
            @{
                'action' = 'upload'
                'contentLength' = 6
                'contentType' = 'text/plain'
                'contentSha1' = '414B40437312266B39986626D35B4BBAED1CA78C2234F26D020E3DB333E64DCD'
                'fileInfo' = @{}
                'fileId' = '4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6b_d20150809_m012853_c100_v0009990_t0000'
                'fileName' = 'files/world.txt'
                'uploadTimestamp' = 1439083733000
            }
    }
    $b2_item_version = @{
        'files' = @{
                'action' = 'upload'
                'contentLength' = 0
                'contentType' = 'text/plain'
                'contentSha1' = 'EB40BC89583313F3A07BC44BF0AA1FF1100C5DB507C853F6D1037B12654EBBFB'
                'fileInfo' = @{}
                'fileId' = '4_z27c88f1d182b150646ff0b16_f100920ddab886247_d20150809_m232323_c100_v0009990_t0005'
                'fileName' = 'files/world.txt'
                'uploadTimestamp' = 1439162603000
            },
            @{
                'action' = 'upload'
                'contentLength' = 6
                'contentType' = 'text/plain'
                'contentSha1' = 'EB40BC89583313F3A07BC44BF0AA1FF1100C5DB507C853F6D1037B12654EBBFB'
                'fileInfo' = @{}
                'fileId' = '4_z27c88f1d182b150646ff0b16_f1004ba650fe24e6b_d20150809_m012853_c100_v0009990_t0000'
                'fileName' = 'files/world.txt'
                'uploadTimestamp' = 1439162596000
            }
    }
    $b2_upload_uri = @{
        'bucketId' = '4a48fe8875c6214145260818'
        'uploadUrl' = 'https://pod-000-1005-03.backblaze.com/b2api/v1/b2_upload_file?cvt=c001_v0001005_t0027&bucket=4a48fe8875c6214145260818'
        'authorizationToken' = '2_20151009170037_f504a0f39a0f4e657337e624_9754dde94359bd7b8f1445c8f4cc1a231a33f714_upld'
    }
    Describe "PS.B2 class tests" {
        Context "Connect-B2Cloud" {
            It "Does not error with valid input" {
                Mock Invoke-RestMethod { return $b2_account }
                {Connect-B2Cloud -AccountID '30f20426f0b1' -ApplicationKey 56709} | Should Not Throw
            }
            It "Returns only 1 account" {
                Mock Invoke-RestMethod { return $b2_account }
                (Connect-B2Cloud -AccountID '30f20426f0b1' -ApplicationKey 56709).Count | Should Be 1
            }
            It "Has the correct type set" {
                Mock Invoke-RestMethod { return $b2_account }
                (Connect-B2Cloud -AccountID 1234 -ApplicationKey 56709).GetType().Name | Should Be 'Account'
            }
        }
        Context "Get-B2Bucket" {
            It "Does not error with valid input" {
                Mock Invoke-RestMethod { return $b2_buckets }
                {Get-B2Bucket} | Should Not Throw
            }
            It "Lists all $($b2_buckets.buckets.Count) examples" {
                Mock Invoke-RestMethod { return $b2_buckets }
                (Get-B2Bucket).Count | Should Be $b2_buckets.buckets.Count
            }
            It "Has the correct type set" {
                Mock Invoke-RestMethod { return $b2_buckets }
                (Get-B2Bucket)[0].GetType().Name | Should Be 'Bucket'
            }
        }
        Context "Get-B2ChildItem" {
            It "Does not error with valid input" {
                Mock Invoke-RestMethod { return $b2_item }
                {Get-B2ChildItem -BucketID 'F@K30UT'} | Should Not Throw
            }
            It "Lists the $($b2_item.files.Count) examples" {
                Mock Invoke-RestMethod { return $b2_item }
                (Get-B2ChildItem -BucketID 'F@K30UT').Count | Should Be $b2_item.files.Count
            }
            It "Accepts pipeline input" {
                # Mock for Get-B2ChildItem
                Mock Invoke-RestMethod { return $b2_item } -ParameterFilter { $Uri -eq $('{0}{1}' -f $b2_account['apiUrl'],'b2api/v1/b2_list_file_names') }
                # Mock for Get-B2Bucket
                Mock Invoke-RestMethod { return $b2_buckets } -ParameterFilter { $Uri -eq $('{0}{1}' -f $b2_account['apiUrl'],'/b2api/v1/b2_list_buckets') }
                {Get-B2Bucket | Get-B2ChildItem} | Should Not Throw
                (Get-B2Bucket | Get-B2ChildItem).Count | Should Be $b2_item.files.Count
            }
            It "Has the correct type set" {
                Mock Invoke-RestMethod { return $b2_item }
                (Get-B2ChildItem -BucketID 'F@K30UT')[0].GetType().Name | Should Be 'File'
            }
        }
        Context "Get-B2ItemProperty" {
            It "Does not error with valid input" {
                # TODO
                $false | Should Be $true
            }
        }
        Context "Get-B2ItemVersion" {
            It "Does not error with valid input" {
                Mock Invoke-RestMethod { return $b2_item_version }
                {Get-B2ItemVersion -BucketID 'F@K30UT'} | Should Not Throw
            }
            It "Lists the $($b2_item_version.files.Count) examples" {
                Mock Invoke-RestMethod { return $b2_item_version }
                (Get-B2ItemVersion -BucketID 'F@K30UT').Count | Should Be $b2_item_version.files.Count
            }
            It "Accepts pipeline input" {
                # Mock for Get-B2ItemVersion
                Mock Invoke-RestMethod { return $b2_item_version } -ParameterFilter { $Uri -eq $('{0}{1}' -f $b2_account['apiUrl'],'/b2api/v1/b2_list_file_versions') }
                # Mock for Get-B2Bucket
                Mock Invoke-RestMethod { return $b2_buckets } -ParameterFilter { $Uri -eq $('{0}{1}' -f $b2_account['apiUrl'],'/b2api/v1/b2_list_buckets') }
                {Get-B2Bucket | Get-B2ItemVersion} | Should Not Throw
                (Get-B2Bucket | Get-B2ItemVersion).Count | Should Be $b2_item.files.Count
            }
            It "Has the correct type set" {
                Mock Invoke-RestMethod { return $b2_item_version }
                (Get-B2ItemVersion -BucketID 'F@K30UT')[0].GetType().Name | Should Be 'File'
            }
        }
        Context "Get-B2UploadUri" {
            It "Does not error with valid input" {
                Mock Invoke-RestMethod { return $b2_upload_uri }
                {Get-B2UploadUri -BucketID 'F@K30UT'} | Should Not Throw
            }
            It "Lists 1 example for a single input" {
                Mock Invoke-RestMethod { return $b2_upload_uri }
                (Get-B2UploadUri -BucketID 'F@K30UT').Count | Should Be 1
            }
            It "Accepts pipeline input" {
                # TODO
                $false | Should Be $true
            }
        }
    }
}