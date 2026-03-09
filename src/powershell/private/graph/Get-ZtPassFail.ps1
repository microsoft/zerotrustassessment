function Get-ZtPassFail {
    <#
.SYNOPSIS
    Returns a pass/fail emoji based on a boolean input.

.DESCRIPTION
    This function takes a boolean input and returns a green check mark (✅) for true and a red cross mark (❌) for false.
.PARAMETER Condition
    A boolean value indicating pass (true) or fail (false).
.EXAMPLE
    Get-ZtPassFail -Condition $true
    Returns: ✅
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,
        [Parameter(Mandatory = $false)]
        [switch]$IncludeText = $false,

        # Type of emoji bubble or check/cross
        [Parameter(Mandatory = $false)]
        [ValidateSet('Check','Bubble')]
        [string]$EmojiType = 'Check'
    )

    if ($EmojiType -eq 'Check') {
        if ($Condition) {
            $emoji = '✅'
            if ($IncludeText) { $emoji += ' Pass' }
        } else {
            $emoji = '❌'
            if ($IncludeText) { $emoji += ' Fail' }
        }
    } elseif ($EmojiType -eq 'Bubble') {
        if ($Condition) {
            $emoji = '🟢'
            if ($IncludeText) { $emoji += ' Pass' }
        } else {
            $emoji = '🔴'
            if ($IncludeText) { $emoji += ' Fail' }
        }
    }
    return $emoji
}
