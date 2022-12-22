function Reset-GitWorkingCopy() {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='High')]
	Param (
		[string] $WorkingCopy = '.',
		[switch] $Hard
	)
	Process {
		$RepoName = Split-Path -Path:(Resolve-Path -Path:$WorkingCopy) -Leaf
		if ($PSCmdlet.ShouldProcess($RepoName, 'Reset working copy')) {
			$CommandArgs = ''
			if ($Hard) { $CommandArgs += '--hard' }
			Invoke-GitCommand -Verb:'reset' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
			Write-Verbose -Message:"Reset $RepoName"
		}
	}
}