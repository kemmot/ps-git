function New-GitCommit() {
	Param (
		[string] $Message = '',
		[string] $WorkingCopy = '.',
		[string] $AuthorName = '',
		[string] $AuthorEmail = '',
		[switch] $All,
		[switch] $Amend,
		[switch] $NoEdit,
		[switch] $AllowEmpty
	)
	Process {
		$CommandArgs = ''
		if (![string]::IsNullOrEmpty($Message)) {
			$CommandArgs += " --message `"$Message`""
		} elseif ($NoEdit) {
			$CommandArgs += " --no-edit"
		}
		
		if ($All) { $CommandArgs += ' --all' }
		if ($Amend) { $CommandArgs += ' --amend' }
		if ($AllowEmpty) { $CommandArgs += ' --allow-empty' }
		
		if (![string]::IsNullOrEmpty($AuthorName) -or ![string]::IsNullOrEmpty($AuthorEmail)) {
			$CommandArgs += " --author '"
			if (![string]::IsNullOrEmpty($AuthorName)) {
				$CommandArgs += "$AuthorName"
			}
			if (![string]::IsNullOrEmpty($AuthorEmail)) {
				if (![string]::IsNullOrEmpty($AuthorName)) { $CommandArgs += ' ' }
				$CommandArgs += "<$AuthorEmail>"
			}
			$CommandArgs += "'"
		}
		
		$Output = Invoke-GitCommand -Verb:'commit' -CommandArgs:$CommandArgs -WorkingCopy:$WorkingCopy
		write-host "Output: $Output"
		$Output | ? { $_ -match '\[.+ (?<hash>\S+)\] \S+' } | %{ Write-Output (New-Object PsObject -Property:@{'Hash'=$matches['hash'] }) }
	}
}