function Test-GitFileRepository() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $Path
	)
	Process {
		$TestPath = [System.IO.Path]::Combine($Path, 'refs')
		$IsGitRepo = Test-Path -Path:$TestPath
		Write-Debug -Message:"Test-GitFileRepository, is git repo: $IsGitRepo, tested path: [$TestPath]"
		return $IsGitRepo
	}
}