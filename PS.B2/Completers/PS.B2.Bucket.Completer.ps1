$argument_completer = @{
    CommandName = @(Get-B2ChildItem)
    ParamterName = BucketID
    ScriptBlock = {
        param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameter)
        $ItemList = Get-B2Bucket | Where-Object { $PSItem.BucketName -match $WordToComplete } | ForEach-Object {
            $CompletionText = $PSItem.BucketID
            $ToolTip = 'The Bucket {0} with ID {1} in account {2}' -f $PSItem.BucketName, $PSItem.BucketID, $PSItem.AccountID
            $ListItemText = 'Bucket {0} ID {1}' -f $PSItem.BucketName, $PSItem.BucketID
            $CompletionResultType = [System.Management.Automation.CompletionResultType]::ParameterValue

            [System.Management.Automation.CompletionResult]::new($CompletionText, $ListItemText, $CompletionResultType, $ToolTip)
        }
        return $ItemList
    }
}

Register-ArgumentCompleter @argument_completer