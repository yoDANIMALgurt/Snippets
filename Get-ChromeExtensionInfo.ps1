Function Get-ChromeExtensionInfo {
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
	[String]$extension_id
	)

	$uri = 'https://api.crxcavator.io/v1/metadata/'+$extension_id
	$info = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction SilentlyContinue | Select extension_id,name,short_description,users,rating,rating_users
	if ($null -eq $info.extension_id){
		Write-Host "Extension `"$extension_id`" could not be retrieved from the Chrome Webstore. This error typically occurs when the extension is a built-in feature published by Google. Other possible reasons for this error include extensions installed from outside of the Chrome Webstore (developer mode), network failure, or API request rate limiting" -BackgroundColor Black -ForeGroundColor Yellow
	}
	else {
	Return $info
	}
}