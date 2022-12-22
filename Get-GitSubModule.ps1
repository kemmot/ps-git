function Get-GitSubModule() {
	Param (
		[string] $WorkingCopy = '.'
	)
	Process {
		Invoke-GitCommand `
				-Verb:'submodule' `
				-CommandArgs:'--quiet foreach ''echo $path''' `
				-WorkingCopy:$WorkingCopy
	}
}