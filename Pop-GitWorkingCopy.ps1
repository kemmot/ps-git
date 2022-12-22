function Pop-GitWorkingCopy() {
	$PreviousBranch = $global:GitWorkingCopyStack.Pop()
	Switch-GitWorkingCopy -RefName:$PreviousBranch
}