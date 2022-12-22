<#
.SYNOPSIS
Removes any branches that has been merged with the current branch.

.OUTPUTS
None.

.PARAMETER TargetBranch
The branch to compare with when deciding if a branch has been merged and can therefore be removed.

.PARAMETER NoPrune
By default, the function will run a prune first. Setting this switch will suppress that.

.PARAMETER LocalOnly
By default, the function will consider both local and remote branches. Setting this switch will cause it to only consider local branches.

.PARAMETER WorkingCopy
Optional parameter allowing the working directory to be overridden before invoking the git command.
If not specified, this will default to the current location.

.NOTES
Respects the $global:PsGitSettings.SacredBranches setting and will not delete any branch listed in it.

.EXAMPLE
Remove-GitMergedBranches -WhatIf

Outputs which branches would be removed if this command were run without protections.

.EXAMPLE
Remove-GitMergedBranches -Confirm:$False -Verbose

Just removes the merged branches without confirmation but does list them.
#>
function Remove-GitMergedBranches() {
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='High')]
    Param (
        [string] $TargetBranch = '',
        [string] $WorkingCopy = '.',
        [switch] $LocalOnly,
        [switch] $NoPrune
    )
    Process {
        $TargetBranchSpecified = $True
        if ([string]::IsNullOrEmpty($TargetBranch)) {
            $TargetBranch = (Get-GitBranch -OnlyCurrent).Name
            $TargetBranchSpecified = $False
        }
        
        if ($TargetBranchSpecified) { Push-GitWorkingCopy -RefName:$TargetBranch }

        if (!$NoPrune) {
            Write-Progress -Activity:'Remove-GitMergedBranches' -Status:'Pruning'
            Get-GitRepositoryChanges -Remote:origin -Prune
        }
        
        Write-Progress -Activity:'Remove-GitMergedBranches' -Status:'Finding local merged branches'
        $MergedBranches = Get-GitBranch -MergedState:'Merged' -IncludeRemote:(!$LocalOnly) | ? { $_.IsCurrent -eq $False }

        Write-Progress -Activity:'Remove-GitMergedBranches' -Status:"About to remove $($MergedBranches.Count) local branches"
        $BranchCount = 0
        foreach ($MergedBranch in $MergedBranches) {
            $CanRemove = $True
            
            # exclude sacred branches
            if ($MergedBranch.Name -in $global:PsGitSettings.SacredBranches) { $CanRemove = $False }
            
            # exclude current branch
            if ($MergedBranch.Name -eq $TargetBranch) { $CanRemove = $False }
            
            if ($CanRemove) {
                Remove-GitBranch -Branch:$MergedBranch
                $BranchCount++
                Write-Progress -Activity:'Remove-GitMergedBranches' -Status:"Removed local branch $BranchCount/$($MergedBranches.Count): $MergedBranch" -PercentComplete:(($BranchCount/$MergedBranches.Count)*100)
            }
        }

        Write-Progress -Activity:'Remove-GitMergedBranches' -Status:'Done' -Completed

        if ($TargetBranchSpecified) { Pop-GitWorkingCopy }
    }
}