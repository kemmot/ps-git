function Merge-GitRepository() {
	Param (
		[string] $WorkingCopy = '.'
	)
	Process {
		Invoke-GitCommand -Verb:'pull' -WorkingCopy:$WorkingCopy
	}
}