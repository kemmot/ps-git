function Get-GitRepositoryChanges() {
	Param (
		[string] $Remote = '',
		[string] $WorkingCopy = '.',
		[switch] $Prune
	)
	Process {
		$CommandArgs = ''
		if (![string]::IsNullOrEmpty($Remote)) { $CommandArgs += $Remote }
		if ($Prune) { $CommandArgs += ' --prune' }
		Invoke-GitCommand -Verb:'fetch' -WorkingCopy:$WorkingCopy -CommandArgs:$CommandArgs
	}
}