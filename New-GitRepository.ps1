function New-GitRepository() {
	Param (
		[string] $WorkingCopy = '.',
		[switch] $Quiet,
		[switch] $Bare
	)
	Process {
		$CommandArgs = ''
		if ($Quiet) { $CommandArgs += '--quiet' }
		if ($Bare)  {
			if ($CommandArgs.Length -gt 0) { $CommandArgs += ' ' }
			$CommandArgs += '--bare'
		}
		
		if (!(Test-Path -Path:$WorkingCopy)) {
			New-Item -Path:$WorkingCopy -ItemType:'Directory' | Out-Null
		}
		
		Invoke-GitCommand -Verb:'init' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
	}
}