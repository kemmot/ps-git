function Test-GitRepository() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $Path
	)
	Process {
		$IsGitRepo = Test-GitFileRepository -Path:$Path
		if (!$IsGitRepo) { $IsGitRepo = Test-GitServerRepository -Path:$Path }
		Write-Debug -Message:"Test-GitRepository, is git repo: $IsGitRepo, tested path: [$Path]"
		return $IsGitRepo
	}
}