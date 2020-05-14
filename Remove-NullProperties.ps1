Function Remove-NullProperties {
Param(  
    [Parameter(Mandatory = $True,Position = 0,ValueFromPipeline = $True)]
	[PSObject]$InputObject
	)
$hash = $InputObject | Get-Member -MemberType *Property | Select-Object -ExpandProperty Name |
Sort-Object |
ForEach-Object -Begin {
  [System.Collections.Specialized.OrderedDictionary]$rv=@{}
  } -process {
if ($InputObject.$_ -ne $null){
	$rv.$_ = $InputObject.$_
  }
#  else
#  {
#    Write-Warning "Removing null valued property $_"
#}
} -end {$rv}
$Output = New-Object PSObject
$Output | Add-Member ($hash) -ErrorAction SilentlyContinue
Return $Output
}
