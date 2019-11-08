Function Get-EmailFileHeaders {
    <#
        .SYNOPSIS
            This PowerShell Function queries a .eml file and returns each header with its value as an array
        .DESCRIPTION
            This PowerShell Function queries a .eml file and returns with its value as an array
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$File
    )
    $HeaderContent = (Get-Content $file -Delimiter "`r`n`r")[0]
    $HeaderContent = $HeaderContent -split "`r`n`(`?`!\s+`)"
    Return $HeaderContent
}
