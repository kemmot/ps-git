function Get-GitTag() {
	Param (
		[string] $WorkingCopy = '.'
	)
	Process {
		Invoke-GitCommand -Verb:'tag' -WorkingCopy:$WorkingCopy
	}
}