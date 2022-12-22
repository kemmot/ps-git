function New-GitWorkingCopy() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $RepositoryPath,
		[Parameter(Mandatory=$True)]
		[string] $WorkingCopy
	)
	Process {
		if (!(Test-Path -Path:$WorkingCopy)) {
			New-Item -ItemType:'Directory' -Path:$WorkingCopy
		}
		
		$CommandArgs = "--progress `"$RepositoryPath`" `"$WorkingCopy`""
		Invoke-GitCommand -Verb:'clone' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
		Write-Verbose -Message:"Created git working copy, [$RepositoryPath] -> [$WorkingCopy]"
	}
}