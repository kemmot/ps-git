Write-Verbose 'Running PsGit.psm1'
$path = Split-Path $script:MyInvocation.MyCommand.Path
Push-Location $path

class GitOutput
{
	[string] $Line
}

class GitBranch : GitOutput
{
    [string]   $Name
    [bool]     $IsCurrent
    [bool]     $IsRemote
    [string]   $FullName
    [string]   $RemoteName
	[string] $Target
}

class GitCommit : GitOutput
{
    [int] $Index
    [string] $Hash
    [string] $Author
}

#if (!(Test-Path variable:Global:GitWorkingCopyStack)) {
    Set-Variable -Scope Global -Name GitWorkingCopyStack -Value (New-Object -TypeName 'System.Collections.Generic.Stack``1[string]')
#}

$global:PsGitSettings = @{}
$global:PsGitSettings.SacredBranches = @('develop', 'HEAD', 'main', 'master')

. .\Add-GitStagedFile.ps1
. .\Invoke-GitCommand.ps1
. .\Invoke-GitGarbageCollector.ps1

# branch functions
. .\Get-GitBranch.ps1
. .\Remove-GitBranch.ps1
. .\Sync-GitBranch.ps1
. .\Test-GitBranch.ps1

# commit functions
. .\New-GitCommit.ps1

# repository functions
. .\Get-GitRepositoryChanges.ps1
. .\Merge-GitRepository.ps1
. .\New-GitRepository.ps1
. .\Push-GitRepository.ps1
. .\Sync-GitRepository.ps1
. .\Test-GitFileRepository.ps1
. .\Test-GitServerRepository.ps1
. .\Test-GitRepository.ps1

# stash functions
. .\Pop-GitStash.ps1
. .\Push-GitStash.ps1

# sub-module functions
. .\Get-GitSubModule.ps1

# tag functions
. .\Get-GitTag.ps1
. .\New-GitTag.ps1
. .\Remove-GitTag.ps1

# working copy functions
. .\Clear-GitWorkingCopy.ps1
. .\Export-GitWorkingCopy.ps1
. .\New-GitWorkingCopy.ps1
. .\Pop-GitWorkingCopy.ps1
. .\Push-GitWorkingCopy.ps1
. .\Reset-GitWorkingCopy.ps1
. .\Switch-GitWorkingCopy.ps1

# helper functions
. .\Remove-GitMergedBranches.ps1

# aliases to make commands with approved Powershell verbs more like original git verbs
Set-Alias -Name:Archive-GitRepository      -Value:Export-GitRepository
Set-Alias -Name:Checkout-GitWorkingCopy    -Value:Switch-GitWorkingCopy
Set-Alias -Name:Clean-GitWorkingCopy       -Value:Clear-GitWorkingCopy
Set-Alias -Name:Clone-GitRepository        -Value:Sync-GitRepository
Set-Alias -Name:Fetch-GitRepositoryChanges -Value:Get-GitRepositoryChanges
Set-Alias -Name:Pull-GitRepository         -Value:Merge-GitRepository

# aliases to match  git
Set-Alias gitcheckout Switch-GitWorkingCopy
Set-Alias gitclean    Clear-GitWorkingCopy
Set-Alias gitclone    Sync-GitRepository
Set-Alias gitcommit   New-GitCommit
Set-Alias gitfetch    Get-GitRepositoryChanges
Set-Alias popwc       Pop-GitWorkingCopy
Set-Alias pushwc      Push-GitWorkingCopy

function Get-GitLog() {
    $Output = git log --pretty=format:'"%h|%an"'
    $Index = 1
    foreach ($OutputLine in $Output) {
        $LineParts = $OutputLine.Split('|')
        $Commit = New-Object GitCommit
        $Commit.Index = $Index
        $Commit.Hash = $LineParts[0]
        $Commit.Author = $LineParts[1]
        Write-Output $Commit
        $Index++
    }
}

function Redo-GitCommit() {
    Param(
        $BranchName,
        $NewAuthor,
        $NewAuthorEmail,
        $UpdateLimit = -1
    )
    Process {
        Switch-GitWorkingCopy -RefName:$BranchName
        Write-Progress -Activity:'Updating commits' -Status:'Getting git log' -PercentComplete:0
        $Commits = Get-GitLog | Sort-Object -Property Index -Descending
        $CommitToFixCount = ($Commits | ? Author -ne $NewAuthor | Measure-Object).Count

        $CommitsComplete = 0
        #$UpdateCount = 0
        do {
            $Stopwatch = New-Object System.Diagnostics.Stopwatch
            $Stopwatch.Start()
            $CommitToFix = Get-GitLog | ? Author -ne $NewAuthor | Sort-Object -Property Index -Descending | Select-Object -First 1
            Write-Progress -Activity:'Updating commits' -Status:"Updating commit $($CommitToFix.Index)/$($Commits.Count): $($CommitToFix.Hash)" -PercentComplete:($CommitsComplete/$CommitToFixCount * 100)
            Write-Host "Commit $($CommitToFix.Index)-$($CommitToFix.Hash) has incorrect author: $($CommitToFix.Author)"
            
            Switch-GitWorkingCopy -RefName:$CommitToFix.Hash
            $NewCommit = New-GitCommit -Amend -AuthorName:$NewAuthor -AuthorEmail:$NewAuthorEmail -NoEdit
            Write-Host "Created new commit: $($NewCommit.Hash)"
            Switch-GitWorkingCopy -RefName:$BranchName
            Write-Host "Switched back to $BranchName"
            git rebase $NewCommit.Hash
            #Invoke-GitCommand -Verb:'rebase' -CommandArgs:"-i $($NewCommit.Hash)"
            Write-Host "Rebased $BranchName"
            #$UpdateCount++
            $CommitsComplete++
            $Stopwatch.Stop()
            Write-Host $Stopwatch.Elapsed
        
            if ($UpdateLimit -gt 0 -and $CommitsComplete -ge $UpdateLimit) {
                break
            }
            
            
        } while ($CommitToFix -ne $null)
        Write-Progress -Activity:'Updating commits' -Completed
    }
}

Pop-Location
