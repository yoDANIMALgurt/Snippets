Function Get-ChromeExtensionRiskScore {
<#
.SYNOPSIS
    Retrieves extension risk score from crxcavator for extension id/version

.DESCRIPTION
    This function performs a Rest API query using Cisco's CRXcavator service. API documentation can be found here: https://crxcavator.io/apidocs

.NOTES
    Written by: Dan Gassensmith
    Last Update: 2020-06-08

.PARAMETER extension_id
    The 32-character unique ID of the extension to query. 
	
.PARAMETER version
    The version of the extension to query

.OUTPUTS
	extension_id - the id of the queried extension
	version - the extension version
	ContentSecurityPolicy - 
	ExternalCalls -
	Permissions - 
	OptionalPermissions - 
	RetireJS - 
	Webstore - 
	Total - 

.EXAMPLE
    PS> Get-ChromeExtensionRiskScore -extension_id cjpalhdlnbpafiamejdnhcphjbkeiagm | ft -a

	extension_id                     version ContentSecurityPolicy ExternalCalls Permissions OptionalPermissions RetireJS Webstore Total
	------------                     ------- --------------------- ------------- ----------- ------------------- -------- -------- -----
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.17.0                    377                       145                  15                 7   544
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.17.4                    377                       145                  15                 7   544
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.0                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.10                   377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.14                   377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.16                   377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.2                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.4                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.6                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.18.8                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.19.0                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.19.2                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.19.4                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.19.6                    377                       145                                     7   529
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.20.0                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.21.0                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.21.2                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.21.4                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.21.6                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.22.0                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.22.2                    377                       145                                     6   528
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.22.4                    377                       145                                     5   527
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.23.0                    377                       145                                     5   527
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.24.2                    377                       145                                     4   526
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.24.4                    377                       145                                     4   526
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.26.0                    377                       145                                     3   525
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.27.10                   377                       145                                     2   524

    This example gets the risk score for all versions of the extension with id 'cjpalhdlnbpafiamejdnhcphjbkeiagm'
	
.EXAMPLE
    PS> Get-ChromeExtensionRiskScore -extension_id cjpalhdlnbpafiamejdnhcphjbkeiagm -version 1.27.10 | ft -a

	extension_id                     version ContentSecurityPolicy ExternalCalls Permissions OptionalPermissions RetireJS Webstore Total
	------------                     ------- --------------------- ------------- ----------- ------------------- -------- -------- -----
	cjpalhdlnbpafiamejdnhcphjbkeiagm 1.27.10                   377                       145                                     2   524
	
	This example gets the risk score for version 1.27.10 of the extension with id 'cjpalhdlnbpafiamejdnhcphjbkeiagm'
#>
Param(
	[Parameter(Mandatory=$true)]
	[String]$extension_id,
	[String]$version
	)
	$output = @()
	if (!$version){
		$uri = 'https://api.crxcavator.io/v1/report/'+$extension_id
	}
	if ($version){
		$uri = 'https://api.crxcavator.io/v1/report/'+$extension_id+'/'+$version
	}
	$riskreports = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction SilentlyContinue
	Foreach ($report in $riskreports){
		$risk = $report | select @{n='extension_id';e={$_.extension_id}},@{n='version';e={$_.version}},@{n='ContentSecurityPolicy';e={$_.data.risk.csp.total}},@{n='ExternalCalls';e={$_.data.risk.extcalls.total}},@{n='Permissions';e={$_.data.risk.permissions.total}},@{n='OptionalPermissions';e={$_.data.risk.optional_permissions.total}},@{n='RetireJS';e={$_.data.risk.retire.total}},@{n='Webstore';e={$_.data.risk.webstore.total}},@{n='Total';e={$_.data.risk.total}}
		$output += $risk
		}
	Return $output
}