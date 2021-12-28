Function Block-ChromeExtension {
Param(
	[String]$ComputerName
	)
	
	if (!$ComputerName){
		$path = 'HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist'
	}
	else {
		$path = '\\'+$ComputerName+'\HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist'
	}

$list = (reg query $path /s) -match "\s+?\d\s+?REG_SZ\s+?\S{32}"|select @{n='entryid';e={($_ -replace "\s+?(\d+?)\s+?REG_SZ.+","`$1")}},@{n='extensionid';e={($_ -replace "\s+?\d+?\s+?REG_SZ\s+?(\S{32})","`$1")}}
$indexstart = $list.count
if (!$ComputerName){
	$targetextensions=(Get-ChromeExtensions | Out-GridView -PassThru|select -ExpandProperty extension_id)
	}
else {
	$targetextensions=(Get-ChromeExtensions -ComputerName $ComputerName | Out-GridView -PassThru|select -ExpandProperty extension_id)
	}
$targetextensions = $targetextensions|?{$_ -notin $list.extensionid}
foreach ($extension in $targetextensions){
	$indexstart++
	reg add $path /v $indexstart /t REG_SZ /d $extension /f
}
}
Function Get-ChromeExtensions {
<#
.SYNOPSIS
    Returns a list of installed extensions for Google Chrome
	
.DESCRIPTION
    This function checks appdata folder(s) to return a list of installed Chrome extensions for a user or computer. If ComputerName or Username is left blank, the query will run on the local system for all users.
	
.NOTES
    Written by: Dan Gassensmith
    Last Update: 2020-06-19
	
.PARAMETER ComputerName
    The hostname of the computer to query. The local system will be queried if this parameter is not specified
	
.PARAMETER Username
	The user ID (as found in C:\Users\) to query for installed extensions
	
.OUTPUTS
	name - The displayname of the extension pulled from manifest
	description - extension description pulled from manifest
	version - extension version number
	extension_id - the 32-character string id of the queried extension
	username - this is the username value for the appdata folder where the extension was found
	path - the local or UNC path where the extension is located
	
.EXAMPLE
    PS> Get-ChromeExtensions
	
	name                      description                                                              version      extension_id                     username         path
	----                      -----------                                                              -------      ------------                     --------         ----
	Slides                    Create and edit presentations                                            0.10         aapocclcgogkmnckokdopfmhonfmgoek DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\aapocclcgogkmnckokdopfmhonfmgoek\0.10_1\manifest.json
	Docs                      Create and edit documents                                                0.10         aohghmighlieiainnegkcijnfilokake DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\aohghmighlieiainnegkcijnfilokake\0.10_1\manifest.json
	Google Drive              Google Drive: create, share and keep all your stuff in one place.        14.2         apdfllckaahabafndbhieahigkjlhalf DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\apdfllckaahabafndbhieahigkjlhalf\14.2_1\manifest.json
	YouTube                                                                                            4.2.8        blpcfgokakmgnkcojhhkbfbldkacnbeo DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\blpcfgokakmgnkcojhhkbfbldkacnbeo\4.2.8_0\manifest.json
	uBlock Origin             Finally, an efficient blocker. Easy on CPU and memory.                   1.24.4       cjpalhdlnbpafiamejdnhcphjbkeiagm DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm\1.24.4_0\manifest.json
	Sheets                    Create and edit spreadsheets                                             1.2          felcaaldnbdncclmgdcncolpebgiejap DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\felcaaldnbdncclmgdcncolpebgiejap\1.2_1\manifest.json
	Google Docs Offline       Get things done offline with the Google Docs family of products.         1.7          ghbmnnjooekpmoecnnnilnnbdlolhkhi DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\ghbmnnjooekpmoecnnnilnnbdlolhkhi\1.7_1\manifest.json
	Chrome Web Store Payments Chrome Web Store Payments                                                1.0.0.5      nmmhkkegccagdldgiimedpiccmgmieda DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\nmmhkkegccagdldgiimedpiccmgmieda\1.0.0.5_0\manifest.json
	Gmail                     Fast, searchable email with less spam.                                   8.2          pjkljhegncpnkpknbcohdijeoejaedia DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\pjkljhegncpnkpknbcohdijeoejaedia\8.2_0\manifest.json
	Chrome Media Router       Provider for discovery and services for mirroring of Chrome Media Router 8320.407.0.1 pkedcjkdefgpdelpbcmbmeomcjbeemfm DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\pkedcjkdefgpdelpbcmbmeomcjbeemfm\8320.407.0.1_0\manifest.json
	Slides                    Create and edit presentations                                            0.10         aapocclcgogkmnckokdopfmhonfmgoek gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\aapocclcgogkmnckokdopfmhonfmgoek\0.10_0\manifest.json
	Docs                      Create and edit documents                                                0.10         aohghmighlieiainnegkcijnfilokake gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\aohghmighlieiainnegkcijnfilokake\0.10_0\manifest.json
	Google Drive              Google Drive: create, share and keep all your stuff in one place.        14.2         apdfllckaahabafndbhieahigkjlhalf gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\apdfllckaahabafndbhieahigkjlhalf\14.2_0\manifest.json
	YouTube                                                                                            4.2.8        blpcfgokakmgnkcojhhkbfbldkacnbeo gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\blpcfgokakmgnkcojhhkbfbldkacnbeo\4.2.8_0\manifest.json
	Sheets                    Create and edit spreadsheets                                             1.2          felcaaldnbdncclmgdcncolpebgiejap gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\felcaaldnbdncclmgdcncolpebgiejap\1.2_0\manifest.json
	Google Docs Offline       Get things done offline with the Google Docs family of products.         1.7          ghbmnnjooekpmoecnnnilnnbdlolhkhi gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\ghbmnnjooekpmoecnnnilnnbdlolhkhi\1.7_1\manifest.json
	Chrome Web Store Payments Chrome Web Store Payments                                                1.0.0.5      nmmhkkegccagdldgiimedpiccmgmieda gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\nmmhkkegccagdldgiimedpiccmgmieda\1.0.0.5_0\manifest.json
	Gmail                     Fast, searchable email with less spam.                                   8.2          pjkljhegncpnkpknbcohdijeoejaedia gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\pjkljhegncpnkpknbcohdijeoejaedia\8.2_0\manifest.json
	Chrome Media Router       Provider for discovery and services for mirroring of Chrome Media Router 8320.407.0.1 pkedcjkdefgpdelpbcmbmeomcjbeemfm gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\pkedcjkdefgpdelpbcmbmeomcjbeemfm\8320.407.0.1_0\manifest.json
	Chrome Media Router       Provider for discovery and services for mirroring of Chrome Media Router 7819.902.0.1 pkedcjkdefgpdelpbcmbmeomcjbeemfm gassensmithd7622 C:\Users\gassensmithd7622\appdata\local\google\chrome\user data\default\extensions\pkedcjkdefgpdelpbcmbmeomcjbeemfm\7819.902.0.1_0\manifest.json
    
	This example gets all installed extensions for all users on the current computer.
	
.EXAMPLE
	PS> Get-ChromeExtensions -ComputerName LAK07N-203779 -Username mstigler-riley | ft -a
	
	name                      description                                                                                                                          version         extension_id                     username       path
	----                      -----------                                                                                                                          -------         ------------                     --------       ----
	Slides                    Create and edit presentations                                                                                                        0.10            aapocclcgogkmnckokdopfmhonfmgoek mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\aapocclcgogkmnckokdopfmhonfmgoek\0.10_0\manifest.json
	My Quick Converter        Search and access popular converter quick links instantly from your new tab page!                                                    7.0             aknlelmioblfeomeemciaomipejabhgk mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\aknlelmioblfeomeemciaomipejabhgk\7.0_0\manifest.json
	Docs                      Create and edit documents                                                                                                            0.10            aohghmighlieiainnegkcijnfilokake mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\aohghmighlieiainnegkcijnfilokake\0.10_0\manifest.json
	Google Drive              Google Drive: create, share and keep all your stuff in one place.                                                                    14.1            apdfllckaahabafndbhieahigkjlhalf mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\apdfllckaahabafndbhieahigkjlhalf\14.1_0\manifest.json
	PackageTracking           Never lose track of a package again! Easily track incoming and outgoing shipping with PackageTrackingâ„¢!                            13.931.18.11269 bamfmecoljgjbaelcceoocomemmncndn mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\bamfmecoljgjbaelcceoocomemmncndn\13.931.18.11269_0\manifest.json
	PackageTracking           Never lose track of a package again! Easily track incoming and outgoing shipping with PackageTrackingâ„¢!                            13.930.17.62268 bamfmecoljgjbaelcceoocomemmncndn mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\bamfmecoljgjbaelcceoocomemmncndn\13.930.17.62268_0\manifest.json
	YouTube                                                                                                                                                        4.2.8           blpcfgokakmgnkcojhhkbfbldkacnbeo mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\blpcfgokakmgnkcojhhkbfbldkacnbeo\4.2.8_0\manifest.json
	Sheets                    Create and edit spreadsheets                                                                                                         1.2             felcaaldnbdncclmgdcncolpebgiejap mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\felcaaldnbdncclmgdcncolpebgiejap\1.2_0\manifest.json
	Google Docs Offline       Edit, create, and view your documents, spreadsheets, and presentations â€” all without internet access.                              1.11.0          ghbmnnjooekpmoecnnnilnnbdlolhkhi mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\ghbmnnjooekpmoecnnnilnnbdlolhkhi\1.11.0_0\manifest.json
	Search Extension by Ask   Convenient browsing tools. Disabling this extension won't uninstall the associated program; for instructions: support.mindspark.com  50.186.18.6636  lgfehfbnofiffladdncogfobimealokp mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\lgfehfbnofiffladdncogfobimealokp\50.186.18.6636_0\manifest.json
	Search Extension by Ask   Convenient browsing tools. Disabling this extension won't uninstall the associated program; for instructions: support.mindspark.com  50.184.17.35688 lgfehfbnofiffladdncogfobimealokp mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\lgfehfbnofiffladdncogfobimealokp\50.184.17.35688_0\manifest.json
	My Quick Converter        Search and access popular converter quick links instantly from your new tab page!                                                    7.0             lmibdmeehggmjlpiafcbanaaecagcfmg mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\lmibdmeehggmjlpiafcbanaaecagcfmg\7.0_0\manifest.json
	Chrome Web Store Payments Chrome Web Store Payments                                                                                                            1.0.0.5         nmmhkkegccagdldgiimedpiccmgmieda mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\nmmhkkegccagdldgiimedpiccmgmieda\1.0.0.5_0\manifest.json
	Gmail                     Fast, searchable email with less spam.                                                                                               8.2             pjkljhegncpnkpknbcohdijeoejaedia mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\pjkljhegncpnkpknbcohdijeoejaedia\8.2_0\manifest.json
	Chrome Media Router       Provider for discovery and services for mirroring of Chrome Media Router                                                             8320.407.0.1    pkedcjkdefgpdelpbcmbmeomcjbeemfm mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\pkedcjkdefgpdelpbcmbmeomcjbeemfm\8320.407.0.1_0\manifest.json
	Chrome Media Router       Provider for discovery and services for mirroring of Chrome Media Router                                                             8220.319.1.2    pkedcjkdefgpdelpbcmbmeomcjbeemfm mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\pkedcjkdefgpdelpbcmbmeomcjbeemfm\8220.319.1.2_0\manifest.json
	Search Encrypt            Keep your searches private by redirecting searches that may be tracked to Search Encrypt, a privacy-focused search engine.           2.2.19          podikjakdikbemkikedommggnijhgnaj mstigler-riley \\LAK07N-203779\c$\Users\mstigler-riley\appdata\local\google\chrome\user data\default\extensions\podikjakdikbemkikedommggnijhgnaj\2.2.19_0\manifest.json
	
	This example gets installed extensions on computer 'LAK07N-203779' for user 'mstigler-riley'
	
.EXAMPLE
	PS> Get-ChromeExtensions -Username dgassensmith8863
	
	name                      description                                                              version      extension_id                     username         path
	----                      -----------                                                              -------      ------------                     --------         ----
	Slides                    Create and edit presentations                                            0.10         aapocclcgogkmnckokdopfmhonfmgoek DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\aapocclcgogkmnckokdopfmhonfmgoek\0.10_1\manifest.json
	Docs                      Create and edit documents                                                0.10         aohghmighlieiainnegkcijnfilokake DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\aohghmighlieiainnegkcijnfilokake\0.10_1\manifest.json
	Google Drive              Google Drive: create, share and keep all your stuff in one place.        14.2         apdfllckaahabafndbhieahigkjlhalf DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\apdfllckaahabafndbhieahigkjlhalf\14.2_1\manifest.json
	YouTube                                                                                            4.2.8        blpcfgokakmgnkcojhhkbfbldkacnbeo DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\blpcfgokakmgnkcojhhkbfbldkacnbeo\4.2.8_0\manifest.json
	uBlock Origin             Finally, an efficient blocker. Easy on CPU and memory.                   1.24.4       cjpalhdlnbpafiamejdnhcphjbkeiagm DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm\1.24.4_0\manifest.json
	Sheets                    Create and edit spreadsheets                                             1.2          felcaaldnbdncclmgdcncolpebgiejap DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\felcaaldnbdncclmgdcncolpebgiejap\1.2_1\manifest.json
	Google Docs Offline       Get things done offline with the Google Docs family of products.         1.7          ghbmnnjooekpmoecnnnilnnbdlolhkhi DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\ghbmnnjooekpmoecnnnilnnbdlolhkhi\1.7_1\manifest.json
	Chrome Web Store Payments Chrome Web Store Payments                                                1.0.0.5      nmmhkkegccagdldgiimedpiccmgmieda DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\nmmhkkegccagdldgiimedpiccmgmieda\1.0.0.5_0\manifest.json
	Gmail                     Fast, searchable email with less spam.                                   8.2          pjkljhegncpnkpknbcohdijeoejaedia DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\pjkljhegncpnkpknbcohdijeoejaedia\8.2_0\manifest.json
	Chrome Media Router       Provider for discovery and services for mirroring of Chrome Media Router 8320.407.0.1 pkedcjkdefgpdelpbcmbmeomcjbeemfm DGassensmith8863 C:\Users\DGassensmith8863\appdata\local\google\chrome\user data\default\extensions\pkedcjkdefgpdelpbcmbmeomcjbeemfm\8320.407.0.1_0\manifest.json
	
	This example gets installed extensions for user 'dgassensmith8863' on the local computer
	
#>
Param(
	[String]$ComputerName,
	[String]$Username
	)
	$TrustedExtensionIDs = @('pkedcjkdefgpdelpbcmbmeomcjbeemfm','nmmhkkegccagdldgiimedpiccmgmieda','aohghmighlieiainnegkcijnfilokake','pjkljhegncpnkpknbcohdijeoejaedia','ghbmnnjooekpmoecnnnilnnbdlolhkhi','apdfllckaahabafndbhieahigkjlhalf','felcaaldnbdncclmgdcncolpebgiejap','aapocclcgogkmnckokdopfmhonfmgoek','blpcfgokakmgnkcojhhkbfbldkacnbeo')
	Function Get-ChromeExtensionLocalManifest {
	Param(
		[Parameter(Mandatory=$true)]
		[String]$extension_id,
		[String]$username,
		[String]$ComputerName,
		[String]$version
		)
	$TrustedExtensionIDs = @('pkedcjkdefgpdelpbcmbmeomcjbeemfm','nmmhkkegccagdldgiimedpiccmgmieda','aohghmighlieiainnegkcijnfilokake','pjkljhegncpnkpknbcohdijeoejaedia','ghbmnnjooekpmoecnnnilnnbdlolhkhi','apdfllckaahabafndbhieahigkjlhalf','felcaaldnbdncclmgdcncolpebgiejap','aapocclcgogkmnckokdopfmhonfmgoek','blpcfgokakmgnkcojhhkbfbldkacnbeo')
		if (!$username){
			$username = '*'
		}
		if (!$version){
			$version = ''
		}
		if (!$ComputerName){
			$path = 'C:\Users\'+$username+'\appdata\local\google\chrome\user data\*\extensions\'+$extension_id+'\'+$version
		}
		else {
			$path = '\\'+$ComputerName+'\c$\Users\'+$username+'\appdata\local\google\chrome\user data\*\extensions\'+$extension_id+'\'+$version
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
		$info = $info | select name,description,version,@{n='extension_id';e={($_.path -replace '.*appdata\\local\\google\\chrome\\user data\\.*\\extensions\\' -replace '\\.*$')}},path | sort name
		Return $info
	}
	if (!$username){
		$username = '*'
	}
	if (!$ComputerName){
		$path = 'C:\Users\'+$username+'\appdata\local\google\chrome\user data\*\extensions\*'
	}
	else {
		$path = '\\'+$ComputerName+'\c$\Users\'+$username+'\appdata\local\google\chrome\user data\*\extensions\*'
	}
	$extensions = get-childitem -Path $path | Select @{n='extension_id';e={$_.name}},@{n='username';e={$_.fullname -replace '\\appdata.*' -replace '.*\\Users\\'}}
	$extensioninfo = @()
	$extensions | %{
		$u = $_.username
		$extensioninfo += Get-ChromeExtensionLocalManifest -extension_id $_.'extension_id' -username $_.username -computername $computername | select name,description,version,extension_id,@{n='username';e={$u}},path
		}
	$extensioninfo = $extensioninfo | Where {$_."extension_id" -notin $TrustedExtensionIDs}
	Return $extensioninfo
}