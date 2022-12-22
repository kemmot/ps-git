function Push-GitStash([string] $WorkingCopy = '.') {
	$Output = Invoke-GitCommand -Verb:'stash' -CommandArgs:'push' -WorkingCopy:$WorkingCopy
    if ($Output -eq 'No local changes to save') { return $False }
    else { return $True }
}
