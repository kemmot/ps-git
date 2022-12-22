<#
.SYNOPSIS
Utility function for invoking a git command.

.OUTPUTS
[String] containing the output of the git command.

.PARAMETER Verb
The branch object to switch/checkout to.

.PARAMETER CommandArgs
The name of the ref to switch/checkout to.  This can be any valid git ref such as a SHA, branch or tag name.

.PARAMETER WorkingCopy
Optional parameter allowing the working directory to be overridden before invoking the git command.
If not specified, this will default to the current location.

.EXAMPLE
Invoke-GitCommand 'checkout' 'develop',

Invokes the 'git checkout develop' command.

.NOTES
The Debug parameter can be used to output the git command generated.
#>
function Invoke-GitCommand() {
	[CmdletBinding(SupportsShouldProcess=$True)]
	Param (
		[string] $Verb,
		[string[]] $CommandArgs = @(''),
		[string] $WorkingCopy = '.'
	)
	Process {
		$Expression = 'git'
		if (![string]::IsNullOrEmpty($Verb)) { $Expression += " $Verb" }
		foreach ($CommandArg in $CommandArgs) { $Expression += " $CommandArg" }
		
		Write-Debug "About to execute expression: $Expression"
		
		if ($PsCmdlet.ShouldProcess($Expression)) {
			Push-Location $WorkingCopy
			$Output = Invoke-Expression $Expression
			Pop-Location
			if ($LASTEXITCODE -ne 0) { Write-Error "Failed executing expression: $($Expression), error code: $LASTEXITCODE" }
			return $Output
		}
	}
}