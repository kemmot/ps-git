function Push-GitRepository() {
	[CmdletBinding(SupportsShouldProcess=$True)]
	Param (
		[Parameter(Mandatory=$False, ParameterSetName='Branch', Position=0)]
		[Parameter(Mandatory=$False, ParameterSetName='BranchName')]
		[Alias('Remote')]
		[Alias('Repo')]
		[string] $RepositoryName = 'origin',
		[Parameter(Mandatory=$True, ParameterSetName='Branch', ValueFromPipeline=$True)]
		[GitBranch] $Branch,
		[Parameter(Mandatory=$True, ParameterSetName='BranchName')]
		[AllowEmptyString()]
		[string] $BranchName,
		[Parameter(Mandatory=$True, ParameterSetName='Branch')]
		[Parameter(Mandatory=$True, ParameterSetName='BranchName')]
		[AllowEmptyString()]
		[AllowNull()]
		[string] $RemoteBranchName,
		[Parameter(Mandatory=$False, ParameterSetName='Ref')]
		[string] $RefSpec = '',
		[Alias('Tags')]
		[switch] $InlcudeTags,
		[string] $WorkingCopy = '.'
	)
	Process {
		$CommandArgs = @('')
		if ($IncludeTags) { $CommandArgs += '--tags' }
		if (![string]::IsNullOrEmpty($RepositoryName)) { $CommandArgs += $RepositoryName }
		switch ($PsCmdlet.ParameterSetName) {
			'Branch' {
				if ([string]::IsNullOrEmpty($RemoteBranchName)) { $RemoteBranchName = $Branch.Name }
				$CommandArgs += " $($Branch.Name):$RemoteBranchName"
			}
			'BranchName' {
				if ([string]::IsNullOrEmpty($RemoteBranchName)) { $RemoteBranchName = $BranchName }
				$CommandArgs += " $($BranchName):$RemoteBranchName"
			}
			'Ref' { if (![string]::IsNullOrEmpty($RefName)) { $CommandArgs += $RefSpec } }
			default { Write-Error "Unknown parameter set: $($PsCmdlet.ParameterSetName)" }
		}
		
		if ($PsCmdlet.ShouldProcess("Remote branch $BranchName")) {
			Invoke-GitCommand -Verb:'push' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy #-Confirm:$False
		}
	}
}