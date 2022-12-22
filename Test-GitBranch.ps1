function Test-GitBranch([string] $Name) {
	$Branches = @(Get-GitBranch -Name:$Name -All | Where-Object { $null -ne $_ })
	if ($Branches.Count -eq 0) { $False } else { $True }
}