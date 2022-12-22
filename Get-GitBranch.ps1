function Get-GitBranch() {
    [CmdletBinding()]
    Param (
        [string] $Name = '',
        [ValidateSet('All', 'Merged', 'Unmerged')]
        [string] $MergedState = 'All',
        [Alias('All')]
        [switch] $IncludeRemote,
        [switch] $OnlyCurrent
    )
    Process {
        $CommandArgs = @()
        if ($IncludeRemote) { $CommandArgs += '--all' }
        
        $CommandArgs += "--format='%(HEAD)|%(objectname:short)|%(refname)|%(committerdate:iso)|%(committer)'"
        
        switch ($MergedState) {
        'All'      { <# do nothing #> }
        'Merged'   { $CommandArgs += '--merged' }
        'Unmerged' { $CommandArgs += '--no-merged' }
        default { Write-Error "Unsupported MergedState: [$MergedState]" }
        }
        
        Invoke-GitCommand -Verb:'branch' -CommandArgs:$CommandArgs  | % {
            $Line = $_
            $LineParts = $LIne.Split('|')
            if ($LineParts.Length -eq 5) {
            #if ($Line -match '^(?<iscurrent>[*])?\s{1,2}(?<fullbranch>(?<isremote>remotes/(?<remote>[^/]+?)/)?(?<branch>.+?))( -> (?<target>.+))?$') {
                $Branch = [GitBranch]::new()
                $Branch.Line = $Line
                $Branch.IsCurrent = ($LineParts[0] -contains '*')
                $Branch.LastCommitSha = $LineParts[1]
                $Branch.FullName = $LineParts[2]
                $Branch.IsRemote = $Branch.FullName.StartsWith('refs/remotes/')
                if ($Branch.IsRemote) {
                    $Branch.RemoteName = $Branch.FullName.Split('/')[2]
                    $Branch.Name = $Branch.FullName.SubString('refs/remotes/'.Length + $Branch.RemoteName.Length + 1)
                } else {
                    $Branch.Name = $Branch.FullName.SubString('refs/heads/'.Length)
                }
                $Branch.LastCommitDate = [DateTime]$LineParts[3]
                $NameAddressDelimiter = $LineParts[4].IndexOf('<')
                $AddressEnd = $LineParts[4].IndexOf('>')
                $Branch.LastCommitName = $LineParts[4].Substring(0, $NameAddressDelimiter - 1)
                $Branch.LastCommitAddress = $LineParts[4].Substring($NameAddressDelimiter + 1, $AddressEnd - $NameAddressDelimiter - 1)
                
                if ($OnlyCurrent -eq $False -or $Branch.IsCurrent) {
                    if ([string]::IsNullOrEmpty($Name) -or $Branch.Name -like $Name) {
                        Write-Output $Branch
                    }
                }
            } else {
                Write-Error "Line format not supported: [$Line]"
            }
        }
    }
}