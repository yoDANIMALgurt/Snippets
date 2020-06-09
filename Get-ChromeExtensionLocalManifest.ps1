Function Get-ChromeExtensionLocalManifest {
<#
.SYNOPSIS
    Looks up Chrome Webstore information for the specified extension id
.DESCRIPTION
    This function performs a Rest API query using Cisco's CRXcavator service. API documentation can be found here: https://crxcavator.io/apidocs
.NOTES
    Written by: Dan Gassensmith
    Last Update: 2020-06-08
.PARAMETER extension_id
    The 32-character unique ID of the extension to query. 
.OUTPUTS
	extension_id - the id of the queried extension
	name - the extension display name
	short_description - brief description of the extension's purpose
	users - total number of Chrome users who use the extension
	rating - average user rating on a scale from 1 to 5
	rating_users - number of users who have submitted a rating for the extension
.EXAMPLE
    PS> Get-ChromeExtensionInfo -extension_id cjpalhdlnbpafiamejdnhcphjbkeiagm
	extension_id      : cjpalhdlnbpafiamejdnhcphjbkeiagm
	name              : uBlock Origin
	short_description : Finally, an efficient blocker. Easy on CPU and memory.
	users             : 10000000
	rating            : 4.7069807
	rating_users      : 22490
    This example gets the extension info for the uBlock Origin extension
#>
Param(
	[Parameter(Mandatory=$true)]
	[String]$extension_id,
	[String]$username,
	[String]$ComputerName,
	[String]$version
	)
	if (!$username){
		$username = '*'
	}
	if (!$version){
		$version = ''
	}
	if (!$ComputerName){
		$path = 'C:\Users\'+$username+'\appdata\local\google\chrome\user data\default\extensions\'+$extension_id+'\'+$version
	}
	else {
		$path = '\\'+$ComputerName+'\c$\Users\'+$username+'\appdata\local\google\chrome\user data\default\extensions\'+$extension_id+'\'+$version
	}
	$manifests = get-childitem -path ($path+'*\manifest.json')
	$info = $manifests | %{
		$p = $_.fullname
		$mm = Get-Content $_ | convertfrom-json | select name,description,default_locale,version,@{n='path';e={$p}}
		if ($mm.name -like '__MSG_*'){
			$searchstring = $mm.name -replace '__MSG_' -replace '_+$' 
			$locale = $mm.default_locale
			$lp = $p -replace '\\manifest\.json',('\_locales\'+$locale+'\messages.json')
			$nn = Get-Content -path $lp | convertfrom-json
			$mm.name = $nn.$searchstring.message
		}
		if ($mm.description -like '__MSG_*'){
			$searchstring = $mm.description -replace '__MSG_' -replace '_+$' 
			$locale = $mm.default_locale
			$lp = $p -replace '\\manifest\.json',('\_locales\'+$locale+'\messages.json')
			$nn = Get-Content -path $lp | convertfrom-json
			$mm.description = $nn.$searchstring.message
		}
		$mm
	}
	$info = $info | select name,description,version,@{n='extension_id';e={($_.path -replace '.*appdata\\local\\google\\chrome\\user data\\default\\extensions\\' -replace '\\.*$')}},path | sort name
	Return $info
}