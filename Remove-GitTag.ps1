function Remove-GitTag() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $Remote,
		[Parameter(Mandatory=$True)]
		[string] $TagName,
		[string] $WorkingCopy = '.',
		[switch] $IsRemote
	)
	Process {
		if ($IsRemote) {
			$CommandArgs = ''
			$CommandArgs = "$Remote :refs/tags/$TagName"
			Invoke-GitCommand -Verb:'push' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
		} else {
			Invoke-GitCommand -Verb:'tag' -CommandArgs:"-d $TagName" -WorkingCopy:$WorkingCopy
		}
	}
}