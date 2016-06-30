<#  
    FrankTucker@lan-sol.com
    New-VMSetup.ps1
    Modify or use as reference
    Most Values or Parms are provide via $splatting = @{ value1 = 1 ; Value2 = 2; Value3 =3 }
#>

#Set-VMHost
    VMHostParms = @{
                VirtualHardDiskPath = "d:\Hyper-V\VHD" ; 
                VirtualMachinePath  = "D:\Hyper-V\ConfigurationFiles" 
                }
    Set-VMHost @VMHostParms 


#Host nework adapter for Hyper-V 
    #You can precheck by manually runing get-netadapter 
    #Find adapter by LinkSpeed 
       #$NetAdapterSpeed = "1 gbps"
       #$NetAdapter = (Get-NetAdapter | Where-Object -FilterScript {$_.LinkSpeed -eq "1 gbps"})
    #Find adapter by InterfaceDescription
       #$NetAdapterInterface = 
       #$NetAdapter = (Get-NetAdapter | Where-Object -FilterScript {$_.InterfaceDescription -eq "$NetAdapterInterface"})
    #Fine adapter by Name
        $FindName = "test"
        $NetAdapter = (Get-NetAdapter | Where-Object -FilterScript {$_.name -eq "$FindName"})


#New-VMSwitch
    #Enter $NetAdapter for NetAdapterName to use value from above
    #VMSwitchType 
        # Allow values [Private, Internal]
        # [NAT] uses NatSubnetAddress = x.x.x.x
        # [External] uses NetAdapterName, implicitly sets type to external
    #AllowManagementoS or Host to share VMSwitch, enter boolean[$True $False]
    #EnableIOV [$true, $false], IOV must be enabled with new, cannot change with set-vmswitch
    $VMSwitchParms = @{
                    NetAdapterName = $NetAdapter.name ;
                    AllowManagementOS = $False        ;
                    Name =  "External"                ;
                    EnableIOV = $false
                    }
    New-VMSwitch @VMSwitchParms

 
#New-VHD 
    #Enter (get-vmhost | Select-Object -Property virutalharddiskpath) to use default hyper-v VHD folder
    #Enter File with extension .vhd .vhdx
    #Do no use "" around value for Size
    #You can find default VHD folder get-vmhost | select-object -property virualharddiskpath
    #Fixed, Enter boolean value [$true $false], $false -eq 
    $VHDparms =@{
            Path  = "d:\hyper-v\VM1_Disk1.vhdx" ;
            Size  = 100gb                   ;
            Fixed = $True                 ;         
            }
    New-vhd @VHDParms                    

     
#New-VM
    #Enter $VHDparms.path as VHDPath to use VHD from above
    #Etner $VMSwitchParms.name as VMSwitch to use VMSwtich form above
    #Enter VHD path as required
    #Do not use "" around value for MemortyStartupBytes
    $VMParms = @{
            VHDPath            = $VHDparms.path      ;
            SwitchName         = $VMSwitchParms.name ;
            Name               = "VM1"              ; 
            Generation         = "2"                 ;
            MemoryStartupBytes =  1gb                ;
            ErrorAction        = "continue"
            }
    new-vm @VMParms


#Set-VMMemory
    #Enter VMParms.name to use VMName above
    #Enter DynamicMemoryEnable as boolean [$True $False]
    #Do not use "" around value for *Bytes
    $VMMemParms = @{
            VMName              = $VMParms.name ;
            DynamicMemoryEnable = $True ;
            StartupBytes  = 1gb  ;
            MinimumBytes  = 1gb  ;
            MaximumBytes  = 4gb  ;
            Priority      = 100  ;
            Buffer        =  50              
            }
    Set-VMMemory @VMMemParms


#VM-Processor
    #Enter VMParms.name to use VMName above
    #Enter values with-out ""
    $VMCpuParms = @{
        VMName  = $VMParms.name ;
        Count   = 4             ;
        Reserve = 10            ;
        Maximum = 75            ;
        RelativeWeight = 100    
        }
    Set-VMProcessor @VMCpuParms


#VM-AutoStart
    #Enter value as ["Nothing", "Start", "StartIfRunning"]
    $VMAutostart = "Nothing"
    Set-vm -VMName $VMParms.name -AutomaticStartAction $VMAutostart


#Cool Server2016, Win10 Stuff configure VM form Host 
     #Enter-PSSession -VMName vmname 
     #Invoke-Command -VMId vmname -ScriptBlock { }

#don't foget |pipe| 
#    Get-vm -name lab* | Get-VMnetworkAdapter | Connect-VMNetworkAdapter -Switchname 'private'