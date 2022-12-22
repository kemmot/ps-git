function Invoke-GitCommand() {
	[CmdletBinding(SupportsShouldProcess=$True)]
	Param (
		[string] $Verb,
		[string[]] $CommandArgs = @(''),
		[string] $WorkingCopy = '.',
		[switch] $What
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