<#
.SYNOPSIS
Removes a local or remote git branch.

.OUTPUTS
None.

.PARAMETER Branch
The branch object to remove.

.PARAMETER BranchName
The name of the branch to remove.

.PARAMETER RepositoryName
The name of the remote repo to work with if different from the default 'origin'.

.PARAMETER WorkingCopy
Optional parameter allowing the working directory to be overridden before invoking the git command.
If not specified, this will default to the current location.

.EXAMPLE
Remove-GitBranch 'test01'

Removes the local branch with name 'test01'.
#>
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
                Write-Verbose "Removed local branch: $BranchName"
            }
        } else {
            if ($PsCmdlet.ShouldProcess("Remote branch $BranchName")) {
                Push-GitRepository -RepositoryName:$RepositoryName -BranchName:'' -RemoteBranchName:$BranchName -WorkingCopy:$WorkingCopy -Confirm:$False
                Write-Verbose "Removed remote branch: $RepositoryName/$BranchName"
            }
        }
    }
}