function Switch-GitWorkingCopy() {
	Param (
		[Parameter(Mandatory=$True, ParameterSetName='Branch', ValueFromPipeline=$True)]
		[GitBranch] $Branch,
		[Parameter(Mandatory=$True, ParameterSetName='Ref')]
		[string] $RefName,
		[Parameter(ParameterSetName='Ref')]
		[switch] $IsTag,
		[string] $WorkingCopy = '.'
	)
	Process {
		$CommandArgs = ''
		switch ($PsCmdlet.ParameterSetName) {
			'Branch' {
				$CommandArgs += $Branch.Name
				$Description = "branch $($Branch.Name)"
			}
			'Ref' {
				if ($IsTag) {
					$CommandArgs += 'tags/'
					$Description = "tag $RefName"
				} else {
					$Description = "branch $RefName"
				}
				$CommandArgs += $RefName
			}
			default { Write-Error "Unknown parameter set: $($Cmdlet.ParameterSetName)" }
		}
		Invoke-GitCommand -Verb:'checkout' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
		Write-Verbose "Switched to $Description"
	}
}