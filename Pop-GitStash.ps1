function Pop-GitStash([string] $WorkingCopy = '.') {
	Invoke-GitCommand -Verb:'stash' -CommandArgs:'pop' -WorkingCopy:$WorkingCopy
}
