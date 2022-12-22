function Export-GitWorkingCopy() {
	Param (
		[Parameter(Mandatory=$True)]
		[string] $ArchivePath,
		[string] $WorkingCopy = '.'
	)
	Process {
		$CommandArgs = "--format=zip --output=`"$ArchivePath`" -0 HEAD"
		Invoke-GitCommand -Verb:'archive' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
	}
}