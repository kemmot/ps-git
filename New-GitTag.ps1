function New-GitTag() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $TagName,
		[string] $WorkingCopy = '.'
	)
	Process {
		Invoke-GitCommand -Verb:'tag' -CommandArgs:"`"$TagName`"" -WorkingCopy:$WorkingCopy
	}
}