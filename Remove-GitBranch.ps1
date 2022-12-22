function Remove-GitBranch() {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='High')]
	Param (
		[Parameter(Mandatory=$True, ParameterSetName='Branch', ValueFromPipeline=$True)]
		<#[GitBranch] #>$Branch,
		[Parameter(Mandatory=$True, ParameterSetName='BranchName')]
		[string] $BranchName,
		[Alias('Remote')]
		[Alias('Repo')]
		[Parameter(Mandatory=$False, ParameterSetName='BranchName')]
		[string] $RepositoryName = 'origin',
		[string] $WorkingCopy = '.'
	)
	Process {
		switch ($PsCmdlet.ParameterSetName) {
			'Branch'     { $BranchName = $Branch.Name; $RepositoryName = $Branch.RemoteName }
			'BranchName' { <# do nothing #> }
			default { Write-Error "Unknown parameter set: $($PsCmdlet.ParameterSetName)" }
		}
		
		$IsLocal = ([string]::IsNullOrEmpty($RepositoryName))
		
		if ($IsLocal) {
			if ($PsCmdlet.ShouldProcess("Local branch $BranchName")) {
				$CommandArgs = @('--delete', $BranchName)
				Invoke-GitCommand -Verb:'branch' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy -Confirm:$False
			}
		} else {
			if ($PsCmdlet.ShouldProcess("Remote branch $BranchName")) {
				Push-GitRepository -RepositoryName:$RepositoryName -BranchName:'' -RemoteBranchName:$BranchName -WorkingCopy:$WorkingCopy -Confirm:$False
			}
		}
	}
}