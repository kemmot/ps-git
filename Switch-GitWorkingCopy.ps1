<#
.SYNOPSIS
Switches to (checks out) a different branch in the git working copy.

.OUTPUTS
None.

.PARAMETER Branch
The branch object to switch/checkout to.

.PARAMETER RefName
The name of the ref to switch/checkout to.  This can be any valid git ref such as a SHA, branch or tag name.

.PARAMETER IsTag
Optional switch parameter that forces the ref name to be treated as a tag.
This is useful if you have both a branch and tag of the same name when git will use the branch in preference.

.PARAMETER WorkingCopy
Optional parameter allowing the working directory to be overridden before invoking the git command.
If not specified, this will default to the current location.

.EXAMPLE
Get-GitBranch 'develop' | Switch-GitWorkingCopy

Switches to a branch returned by the Get-GitBranch function.

.EXAMPLE
Switch-GitWorkingCopy 'release-4.2' -IsTag

Switches to a specified tag.

.NOTES
The Debug parameter can be used to output the git command generated.
#>
function Switch-GitWorkingCopy() {
	[CmdletBinding(DefaultParameterSetName='Ref', SupportsShouldProcess=$True)]
	Param (
		[Parameter(Mandatory=$True, ParameterSetName='Branch', Position=1, ValueFromPipeline=$True)]
		[GitBranch] $Branch,
		[Parameter(Mandatory=$True, ParameterSetName='Ref', Position=1)]
		[string] $RefName,
		[Parameter(ParameterSetName='Ref')]
		[switch] $IsTag,
		[Parameter(Mandatory=$False, ParameterSetName='Branch')]
		[Parameter(Mandatory=$False, ParameterSetName='Ref')]
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