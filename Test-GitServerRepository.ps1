function Test-GitServerRepository() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $Path
	)
	Process {
		$IsGitRepo = $Path.EndsWith('.git')
		Write-Debug -Message:"Test-GitServerRepository, is git repo: $IsGitRepo, tested path: [$Path]"
		return $IsGitRepo
	}
}