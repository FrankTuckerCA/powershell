Function Find-SMBShare 
{
    #FrankTucker@lan-sol.com
    #Requires -Runasadministrator 
    #Requires -Version 3.0 

    <#
	.SYNOPSIS
		 Function searchs for shared items on a computer/s and reports
	.EXAMPLE
		PS> Find-SMBShare -Computername Workstation1 -Credential domain\username

        ComputerName  : Workstation1
        Status        : Connected
        TotalShare    : 8
        AdminShare    : {ADMIN$, C$, E$...}
        PrinterShare  : Brother7840BW, CannonColor
        NotAdminFound : True
        NotAdminShare : DDrive
	
		This example finds shared items on \\Workstation1.
    .EXAMPLE
        PS> $Credential = (Get-Credential)
        PS> Find-SMBShare -Computername Server,Workstation1 -Credential $Credential
        
        This example finds shared items on \\Server and \\Workstation1 with a saved PSCredential
    .EXAMPLE
        PS> Find-SMBShare -Computername Server
        
        This example finds shared items on \\Server with the current logon user credential.   
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
        [object[]]$ComputerName,

        [parameter(Mandatory=$False,
                    ValueFromPipeLine=$False,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="Admin. Username. Or. PSCredential")]
        [Alias('user','username','pscredential')]
        [object]$Credential      
    )   
    Write-Verbose "Checking Credential Param"
    if  ($Credential.count -ne 0)
    {       
        if ($Credential.ToString() -contains 'System.Management.Automation.PSCredential')
        {
            $PSCredential = $Credential           
        }
         else
        {
        Write-Verbose "Getting Credential"
        $PSCredential = (Get-Credential -Credential $Credential)       
        }
      
     }
     Write-Verbose "Checking ComputeName Param"
     if ($ComputerName.count -eq 0)
     {
     $ComputerName = $env:COMPUTERNAME
     }

    foreach ($computer in $computername)
    {
        try
        {
            Write-Verbose "Connecting to $computer"
            
                if ($PSCredential.count -ne 0)
                {
                $Session = New-CimSession -ComputerName $Computer -Credential $PSCredential -ErrorAction Stop
                }
                else
                {
                $Session = New-CimSession -ComputerName $computer -ErrorAction stop
                }

            Write-Verbose "Getting Data from $computer"   
                 
            $Share = ( Get-CimSession -InstanceId $Session.InstanceId | Get-CimInstance -ClassName Win32_Share)
            $PrinterShare = ($Share | Where-Object {$_.name -notlike '*$*'} | Where-Object {$_.path -notlike '*:\*'})
            $AdminShare = ($share | Where-Object {$_.type -ne 0 } | Where-Object {$_.name -like '*$' } )
            $NotAdminShare = ($share | Where-Object {$_.type -eq 0} |  Where-Object {$_.name -notlike '*$'} )               

            $Properties = [ordered]@{ComputerName = $computer
                        Status = 'Connected'
                        TotalShare = $share.count
                        AdminShare = $adminShare.name
                        PrinterShare = $printershare.name
                        NotAdminFound = [boolean]$NotAdminShare
                        NotAdminShare = $notadminshare.name}

        Remove-CimSession -instanceID $Session.InstanceId
        } 
        catch
        {
            Write-Verbose "Couldn't connect to $computer"
            Write-Verbose "Check Credential"
            $properties = [ordered]@{ComputerName = $comptuer
                        Status = 'Disconnected'
                        TotalShare = $null
                        AdminShare = $null
                        PrinterShare = $null
                        NotAdminFound = [boolean]$null
                        NotAdminShare = $null}
        } 
        finally
        {
            $Obj = New-Object -TypeName PSObject -Property $properties
            Write-Output $Obj
        }
    }
}
                        
                        
                        






