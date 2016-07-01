#PowerShell Reference
#FrankTucker@lan-sol.com

#Network Troubleshooting, replaces: ping, telnet port check, tracert
Test-NetConnection hostname -TraceRoute -Port 25 

#Domain/Trust check or repair computer AD Account
Test-ComputerSecureChannel -Credential domain\admin -Repair

#Reset AD User Password & Force change
Set-ADAccountPassword ForgetfulUser -NewPassword newpass -Reset -PassThru | Set-Aduser -ChangePasswordAtLogon $True

#Search-ADAccount 
Search-ADAccount -AccountDisabled -PasswordNeverExpires -AccountInactive -TimeSpace 90.00:00:00

#Firewall
    $FireParms = @{
                DisplayGroup = "Windows Remote Management" ;
                Profile      = "Domain, Private"    ;
                Enable       = $True 
                }
    Set-NetFirewallRule @FireParms

#Services to autostart. Status = [Running, Stopped, Paused]
    $ServiceParms = @{
                    Name        = "WinRM"     ;
                    StartupType = "Automatic" ;
                    Status      = "Running"   ;
                    }
    Set-Service @ServiceParms

    stop-service -Name WinRM
    Start-service -name winrm 
    Get-Service -name winrm

#Splatting Example: VM
    VMParms = @{
        Name = VM1
        MemoryStartupBytes = 2gb
        Generation =2
        BootDevice = CD
        VHDPath = 'd:\hyper-v\vhd.vhdx'
        }
    New-VM @VMParms                    

#Export Drivers 
    Export-WindowsDriver -Path "\\server\temp\lap1_drvexport"
    Dism /Online /Export-Driver /Destination:D:\path

#Import Drivers (You can import drivers to offline .wim) (You can just have Device Manager search path)
    Add-WindowsDriver -ForceUnsigned -Driver -ErrorVariable


#PSRemoting
    $session = New-PSSession -ComputerName wks1,server,ad1 -Credential domain\username
    $session | Remove-PSSession
    Get-PSSession

#Invoke
    Invoke-CimMethod   -ClassName win32_process  -MethodName "create" -Arguments @{ commandline = "notepad.exe" } 
    Invoke-Command -ComputerName $computers { get-hotfix }
    Invoke-Command -Session
    Invoke-Command -ScriptBlock { & C:\windows\system32\wusa.exe $LocalTemp /quiet /norestart}

#Cim
    $Session = New-CimSession -ComputerName $Computer -Credential
    Get-CimInstance -CimSession $Session -ClassName win32_process 


#Sort, SubString (remove chars from string), 
    $Hotfix = ((Get-Hotfix | Sort InstalledOn)[-1])
    $HotFixID = $Hotfix.HotFixID.ToString().substring(2)

#Filter, Select-Object, Where-Object
    Get-Service | Where-Object -Filter {$_.status -eq 'running'}
    Get-ChildItem -path c:\users\*.pdf -Recurse
    $NotAdminShare = ($share | Where-Object {$_.type -eq 0} |  Where-Object {$_.name -notlike '*$'} )
    $Computers = (Get-ADComputer -LDAPFilter "(name=*)" -SearchBase "CN=Computers,DC=NAMEOFDOMAIN,DC=COM")


#ConvertTo
    ConvertTo-Html -Title Report -Head Report | Out-File c:\users\htm.htm
    ConvertTo-Csv
    ConvertTo-Json -InputObject 

#Installing software
    #Two modules 
        SoftwareInstallManger by Adbertram
        Cardon
         
#Imaging Deploying
    #Module
    DeployImage by EnergizedTech
    https://blogs.technet.microsoft.com/heyscriptingguy/2015/12/07/use-deployimage-module-and-powershell-to-build-a-nano-server-part-1/


#Firewall Settings etc..   
    $FireProfile = Get-NetFirewallProfile
    $FireState = ($FireProfile | Where-Object {$_.enabled -like "true"})
    $FireRule = Get-NetFirewallRule
    $FirePublicInbound = ($FireRule  | Where-Object {$_.Profile -like "public" -and $_.Direction -like "inbound" -and $_.Action -like "allow"} )
    $FirePublicOutbound = ($FireRule | Where-Object {$_.Profile -like "public" -and $_.Direction -like "outbound" -and $_.Action -like "allow"} )

#Anti-Virus and Anti-spyware
    $AntiSpyware = (Get-CimInstance -Namespace root/securitycenter2 -ClassName AntiSpywareProduct)
    $AntiVirus = (Get-CimInstance -Namespace root/securitycenter2 -ClassName AntiVirusProduct)
    #Convert Anti Product State to Hex
    $AntiSpywareState = '{0:x}' -f $AntiSpyware.productState
    $AntiVirusState = '{0:x}' -f $AntiVirus.productState


#Server Setup
    #1 Set IP & ComputerName
        Set-NetIPAddress -IPAddress 10.20.30.5 -PrefixLength 24 
        Rename-Computer -ComputerName MDTServer -Restart
    #2 Install ADDS
        Install-WindowsFeature AD-Domain-Services
    #3 Setup Domain Forest, Enter Directory Restore Password between "" 
        $DRpassword = "1Simple.Deploy.Password"
        $SKey = (ConvertTo-SecureString $DRpassword -AsPlainText -Force)
        Install-ADDSForest -SkipPreChecks -DomainName deploy.local -ForestMode win2012r2 -SafeModeAdministratorPassword 
    #4 Install DHCP
        Install-WindowsFeature dhcp
    #5 Configure DHCP 
        Set-DHCPServerV4OptionValue -computername MDTServer.deploy.local -DnsServer 10.20.30.5 -DNSDomain deploy.local -Router 10.20.30.5 `
            -optionid 66 -value MDTServer.deploy.local
        Add-DHCPServer4Scope -Name "DeployNetwork" -StartRange 10.20.30.100 -EndRange 10.20.30.200 -SubNetMask 255.255.255.0 -State Active
    #5 Install WSUS Feature, Setup WSUS
        Install-WindowsFeature UpdateServices -WidDB
        md c:\WSUS
        "c:\ProgramFiles\Update Services\Tools\wsusutil.exe" postinstall CONTENT_DIR=C:\WSUS
        #6 WSUS  Get-Command -Noun *WSUS*
             Get-WsusUpdate 
            #Cleanup WSUS Database
            Invoke-WSUSServerCleanup -CleanupObsoleteComptuers -CleanupObsoleteUpdates
    #6 Install WDS
        Install-WindowsFeature wds -InculdeAllSubFeature -InculdeManagementTools -restart 
    #7 AFTER you setup MDT
        #Location of MDT Boot.wim Default \\mdt\deploy\boot\LiteTouchPE_x64.wim
        Import-WDSBootImage 

#Robo Copy
	robocopy \\Netbios\Share\Data  d:\backup\Netbios\Data_backup_folder  /mir /mt /log:d:\backup\Netbios\Netbios_data_backup_log.txt

	* /e	= copy all sub-directories, even empty
	* /s	= copy all sub-directories, but not empty
	* /purge = delete dest files/dirs that no longer exist in source
	* /mir  = mirror (check, copy only new files, delete dest file if source missing)
		* /mir = /e /purge
	* /np   = no progress counter
	* /log: = create log file
	* /w:   = wait time in secs (if file in-use) (30 sec default w/o entering switch)
	* /mt:	= mulit-threaded (8 threads default if entered switch)
	* /z:   = retry if network connection is lost
	* /move  = MOVE files and Directorys
	* /mov = MOVe files (delete source)
	* /mon:n = MONitor source; run again when more than n changes seen
	* /mot:m = MoniTor source; run again when in m minutes time, if changed
	* /rh:hhmm-hhmm = Run Hours; times when new copies may be started