function Clear-GitWorkingCopy() {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='High')]
	Param (
		[string] $WorkingCopy = '.'
	)
	Process {
		$RepoName = Split-Path -Path:(Resolve-Path -Path:$WorkingCopy) -Leaf
		if ($PSCmdlet.ShouldProcess($RepoName, 'Clean working copy')) {
			Invoke-GitCommand -Verb:'clean' -CommandArgs:'--force' -WorkingCopy:$WorkingCopy
			Write-Verbose -Message:"Cleaned $RepoName"
		}
	}
}