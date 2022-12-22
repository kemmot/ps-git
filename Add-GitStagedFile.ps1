function Add-GitStagedFile() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $Filename,
		[string] $WorkingCopy = '.'
	)
	Process {
		Invoke-GitCommand -Verb:'add' -CommandArgs:"`"$Filename`"" -WorkingCopy:$WorkingCopy
	}
}