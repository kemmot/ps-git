function Push-GitWorkingCopy([string] $RefName = '') {
	$CurrentBranch = Get-GitBranch -OnlyCurrent
	$global:GitWorkingCopyStack.Push($CurrentBranch.Name)
	Write-Verbose "Branch $($CurrentBranch.Name) pushed to stack"
	if (![string]::IsNullOrEmpty($RefName)) {
		Switch-GitWorkingCopy -RefName:$RefName
	}
}