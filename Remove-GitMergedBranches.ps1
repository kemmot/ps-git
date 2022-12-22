function Remove-GitMergedBranches([string] $TargetBranch = '', [switch] $LocalOnly) {
	Push-GitWorkingCopy -RefName:$TargetBranch
	
	Write-Progress -Activity:'Remove-GitMergedBranches' -Status:'Pruning'
	Get-GitRepositoryChanges -Remote:origin -prune
	
	Write-Progress -Activity:'Remove-GitMergedBranches' -Status:'Finding local merged branches'
	$MergedBranches = Get-GitBranch -MergedState:'Merged' -IncludeRemote:(!$LocalOnly) | ? { $_.IsCurrent -eq $False }
	
	Write-Progress -Activity:'Remove-GitMergedBranches' -Status:"About to remove $($MergedBranches.Count) local branches"
	$BranchCount = 0
	foreach ($MergedBranch in $MergedBranches) {
		Remove-GitBranch -Branch:$MergedBranch -Confirm
		$BranchCount++
		Write-Progress -Activity:'Remove-GitMergedBranches' -Status:"Removed local branch $BranchCount/$($MergedBranches.Count): $MergedBranch" -PercentComplete:(($BranchCount/$MergedBranches.Count)*100)
	}
	
	Write-Progress -Activity:'Remove-GitMergedBranches' -Status:'Done' -Completed
	
	Pop-GitWorkingCopy
}