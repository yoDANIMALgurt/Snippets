Function Get-ChromeExtensions {
<#
.SYNOPSIS
    Returns a list of installed extensions for Google Chrome
.DESCRIPTION
    This function checks appdata folder(s) to return a list of installed Chrome extensions for a user or computer. If ComputerName or Username is left blank, the query will run on the local system for all users.
.NOTES
    Written by: Dan Gassensmith
    Last Update: 2020-06-08
.PARAMETER ComputerName
    The hostname of the computer to query. The local system will be queried if this parameter is not specified
	
.PARAMETER Username
	The user ID (as found in C:\Users\) to query for installed extensions
.OUTPUTS
	extension_id - the 32-character string id of the queried extension
	username - this is the username value for the appdata folder where the extension was found
.EXAMPLE
    PS> Get-ChromeExtensions
	extension_id                     username
	----                             --------
	aapocclcgogkmnckokdopfmhonfmgoek DGassensmith8863
	aohghmighlieiainnegkcijnfilokake DGassensmith8863
	apdfllckaahabafndbhieahigkjlhalf DGassensmith8863
	blpcfgokakmgnkcojhhkbfbldkacnbeo DGassensmith8863
	cjpalhdlnbpafiamejdnhcphjbkeiagm DGassensmith8863
	felcaaldnbdncclmgdcncolpebgiejap DGassensmith8863
	ghbmnnjooekpmoecnnnilnnbdlolhkhi DGassensmith8863
	nmmhkkegccagdldgiimedpiccmgmieda DGassensmith8863
	pjkljhegncpnkpknbcohdijeoejaedia DGassensmith8863
	pkedcjkdefgpdelpbcmbmeomcjbeemfm DGassensmith8863
	aapocclcgogkmnckokdopfmhonfmgoek gassensmithd7622
	aohghmighlieiainnegkcijnfilokake gassensmithd7622
	apdfllckaahabafndbhieahigkjlhalf gassensmithd7622
	blpcfgokakmgnkcojhhkbfbldkacnbeo gassensmithd7622
	felcaaldnbdncclmgdcncolpebgiejap gassensmithd7622
	ghbmnnjooekpmoecnnnilnnbdlolhkhi gassensmithd7622
	nmmhkkegccagdldgiimedpiccmgmieda gassensmithd7622
	pjkljhegncpnkpknbcohdijeoejaedia gassensmithd7622
	pkedcjkdefgpdelpbcmbmeomcjbeemfm gassensmithd7622
    This example gets all installed extensions for all users on the current computer.
	
.EXAMPLE
	PS> Get-ChromeExtensions -ComputerName LAK03S-176426 -Username dgassensmith8863
	
	extension_id                     username
	----                             --------
	aapocclcgogkmnckokdopfmhonfmgoek dgassensmith8863
	aohghmighlieiainnegkcijnfilokake dgassensmith8863
	apdfllckaahabafndbhieahigkjlhalf dgassensmith8863
	blpcfgokakmgnkcojhhkbfbldkacnbeo dgassensmith8863
	cjpalhdlnbpafiamejdnhcphjbkeiagm dgassensmith8863
	felcaaldnbdncclmgdcncolpebgiejap dgassensmith8863
	ghbmnnjooekpmoecnnnilnnbdlolhkhi dgassensmith8863
	nmmhkkegccagdldgiimedpiccmgmieda dgassensmith8863
	pjkljhegncpnkpknbcohdijeoejaedia dgassensmith8863
	pkedcjkdefgpdelpbcmbmeomcjbeemfm dgassensmith8863
	
	This example gets installed extensions on computer 'LAK03S-176426' for user 'dgassensmith8863'
	
.EXAMPLE
	PS> Get-ChromeExtensions -Username dgassensmith8863
	
	extension_id                     username
	----                             --------
	aapocclcgogkmnckokdopfmhonfmgoek dgassensmith8863
	aohghmighlieiainnegkcijnfilokake dgassensmith8863
	apdfllckaahabafndbhieahigkjlhalf dgassensmith8863
	blpcfgokakmgnkcojhhkbfbldkacnbeo dgassensmith8863
	cjpalhdlnbpafiamejdnhcphjbkeiagm dgassensmith8863
	felcaaldnbdncclmgdcncolpebgiejap dgassensmith8863
	ghbmnnjooekpmoecnnnilnnbdlolhkhi dgassensmith8863
	nmmhkkegccagdldgiimedpiccmgmieda dgassensmith8863
	pjkljhegncpnkpknbcohdijeoejaedia dgassensmith8863
	pkedcjkdefgpdelpbcmbmeomcjbeemfm dgassensmith8863
	
	This example gets installed extensions for user 'dgassensmith8863' on the local computer
	
#>
Param(
	[String]$ComputerName,
	[String]$Username
	)
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
	if (!$username){
		$username = '*'
	}
	if (!$ComputerName){
		$path = 'C:\Users\'+$username+'\appdata\local\google\chrome\user data\default\extensions\*'
	}
	else {
		$path = '\\'+$ComputerName+'\c$\Users\'+$username+'\appdata\local\google\chrome\user data\default\extensions\*'
	}
	$extensions = get-childitem -Path $path | Select @{n='extension_id';e={$_.name}},@{n='username';e={$_.fullname -replace '\\appdata.*' -replace '.*\\Users\\'}}
	$extensioninfo = @()
	$extensions | %{
		$u = $_.username
		$extensioninfo += Get-ChromeExtensionLocalManifest -extension_id $_.'extension_id' -username $_.username -computername $computername | select name,description,version,extension_id,@{n='username';e={$u}},path
		}
	Return $extensioninfo
}
