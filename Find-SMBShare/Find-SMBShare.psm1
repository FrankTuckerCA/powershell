Function Find-SMBShare {
 
#franktucker@lan-sol.com
#requires -runasadministrator 
#requires -version 3.0 

<#
	.SYNOPSIS
		 Function searchs for shared items on a computer/s and reports
	.EXAMPLE
		PS> find-smbshare -computername workstation1 -credential domain\username

        ComputerName  : workstation1
        Status        : Connected
        TotalShare    : 8
        AdminShare    : {ADMIN$, C$, E$...}
        PrinterShare  : Brother7840BW, CannonColor
        NotAdminFound : True
        NotAdminShare : DDrive
	
		This example finds shared items on \\workstation1.
    .EXAMPLE
        PS> $credential = (get-credential)
        PS> find-smbshare -computername server -credential $credential
        
        This example finds shared items on \\server with a saved pscredential
    .PARAMETER computername
		The computer/s to search 
	.PARAMETER credential
		Administrative account on computer/s
        Can be a [string]username or [object]pscredential
	#>

[cmdletBinding()]
param(
        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   HelpMessage="The. Computer. Name.")]
        [Alias('Hostname','cn')]
        [string[]]$ComputerName,

        [parameter(Mandatory=$True,
                    ValueFromPipeLine=$True,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="Admin. Username. Or. PSCredential")]
        [Alias('user','username','pscredential')]
        [object]$Credential      
)   

       
if ($Credential.ToString() -contains 'System.Management.Automation.PSCredential'){
        $pscredential = $Credential}
    else{
        Write-Verbose "getting credential"
        $pscredential = (Get-Credential -Credential $Credential)}  

foreach ($computer in $computername){
    try {
        Write-Verbose "Connecting to $computer"
        $Session = New-CimSession -ComputerName $Computer -Credential $pscredential -ErrorAction Stop 
        Write-Verbose "Get Data from $computer"        
        $Share = ( Get-CimSession -InstanceId $Session.InstanceId | Get-CimInstance -ClassName Win32_Share)
        $PrinterShare = ($Share | Where-Object {$_.name -notlike '*$*'} | Where-Object {$_.path -notlike '*:\*'})
        $AdminShare = ($share | Where-Object {$_.type -ne 0 } | Where-Object {$_.name -like '*$' } )
        $NotAdminShare = ($share | Where-Object {$_.type -eq 0} |  Where-Object {$_.name -notlike '*$'} )               
        $properties = [ordered]@{ComputerName = $computer
                        Status = 'Connected'
                        TotalShare = $share.count
                        AdminShare = $adminShare.name
                        PrinterShare = $printershare.name
                        NotAdminFound = [boolean]$NotAdminShare
                        NotAdminShare = $notadminshare.name}
        Remove-CimSession -instanceID $Session.InstanceId

        } catch {
            Write-Verbose "Couldn't connect to $computer"
            Write-Verbose "Check Credential"
            $properties = [ordered]@{ComputerName = $comptuer
                        Status = 'Disconnected'
                        TotalShare = $null
                        AdminShare = $null
                        PrinterShare = $null
                        NotAdminFound = [boolean]$null
                        NotAdminShare = $null}
        } finally {
            $obj = New-Object -TypeName PSObject -Property $properties
            Write-Output $obj
        }
    }
}

                        
                        
                        






