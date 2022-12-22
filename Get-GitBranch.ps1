function Get-GitBranch() {
	[CmdletBinding()]
	Param (
		[string] $Name = '',
		[ValidateSet('All', 'Merged', 'Unmerged')]
		[string] $MergedState = 'All',
		[Alias('All')]
		[switch] $IncludeRemote,
		[switch] $OnlyCurrent
	)
	Process {
		$CommandArgs = @()
		if ($IncludeRemote) { $CommandArgs += '--all' }
		
		switch ($MergedState) {
		'All'      { <# do nothing #> }
		'Merged'   { $CommandArgs += '--merged' }
		'Unmerged' { $CommandArgs += '--no-merged' }
		default { Write-Error "Unsupported MergedState: [$MergedState]" }
		}
		
		Invoke-GitCommand -Verb:'branch' -CommandArgs:$CommandArgs  | % {
			$Line = $_
			if ($Line -match '^(?<iscurrent>[*])?\s{1,2}(?<fullbranch>(?<isremote>remotes/(?<remote>[^/]+?)/)?(?<branch>.+?))( -> (?<target>.+))?$') {
				$Branch = [GitBranch]::new()
				$Branch.Line = $Line
				$Branch.IsCurrent = ($matches['iscurrent'].Length -gt 0)
				$Branch.FullName = $matches['fullbranch']
				$Branch.Name = $matches['branch']
				$Branch.IsRemote = ($matches['isremote'].Length -gt 0)
				$Branch.RemoteName = $matches['remote']
				$Branch.Target = $matches['target']
				
				if ($OnlyCurrent -eq $False -or $Branch.IsCurrent) {
					if ([string]::IsNullOrEmpty($Name) -or $Branch.Name -like $Name) {
						Write-Output $Branch
					}
				}
			} else {
				Write-Error "Line format not supported: [$Line]"
			}
		}
	}
}