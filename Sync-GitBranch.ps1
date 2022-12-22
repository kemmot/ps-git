function Sync-GitBranch([string] $BranchName, [string] $RemoteName = 'origin', [switch] $Fetch) {
    if ($Fetch) { Get-GitRepositoryChanges }
    $IsStashed = Push-GitStash
    Push-GitWorkingCopy $BranchName
    git merge "$RemoteName/$BranchName"
    Pop-GitWorkingCopy
    if ($IsStashed) { Pop-GitStash }
}