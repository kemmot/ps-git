function Sync-GitRepository() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $RepositoryPath,
		[Parameter(Mandatory=$True)]
		[string] $WorkingCopy,
		[switch] $Recursive,
		[switch] $Progress
	)
	Process {
		$CommandArgs = ''
		if ($Recursive) { $CommandArgs += '--recursive' }
		if ($Progress)  { $CommandArgs += '--progress'  }
		$CommandArgs += "`"$RepositoryPath`" `"$WorkingCopy`""
		Invoke-GitCommand -Verb:'clone' -CommandArgs:$CommandArgs
	}
}