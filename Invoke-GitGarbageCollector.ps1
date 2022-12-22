function Invoke-GitGarbageCollector() {
	Param (
		[string] $WorkingCopy = '.',
		[switch] $Arrgressive,
		[switch] $Force,
		[switch] $NoPrune,
		[switch] $Quiet
	)
	Process {
		Write-Error -Message:'Invoke-GitGarbageCollector not implemented'
	}
}