<# 
PS1SequentialTask
FrankTuckerCA
3 functions: new-ps1sequentialadvtask, start-ps1sequentialadvtask, start-ps1sequentialtask
#> 
function New-PS1SequentialAdvTask{
    <#
    .SYNOPSIS
        Creates JsonTask file for Start-PS1SequentialAdvTask. 
    
    .DESCRIPTION
        Auto create a json file with ps1 scripts pre-entered.
        Or create an example json file with-out pre-enter scripts.
        Json file has two parts: list of scripts and settings.
    
    .PARAMETER $PS1Folder 
        Folder with *.ps1 scripts. Json file will be save here.
    
    .PARAMETER $JsonExample
        Switch to create a json example file.
    
    .PARAMETER $JsonPath
        Path to output json example file. 
    
    .PARAMETER $JsonFile
        Filename to use for json example file
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'PS1Folder')]
    param (
        [Parameter(Mandatory = $true,
        ParameterSetName     = 'PS1Folder',
        Helpmessage          = 'All scripts.ps1 files in folder entered into json file by ascending ordered. Json file will be saved to this folder')]
        [String]$PS1Folder,     
            
        [Parameter(Mandatory = $true,
        ParameterSetName     = 'JsonExample',
        HelpMessage          = 'Will not add any scripts. A example json file will be created')]
        [Switch]$JsonExample,
    
        [Parameter (Mandatory = $true, ParameterSetName = "JsonExample",
        HelpMessage           = 'Path to save json example file ')]
        [String]$JsonPath,
    
        [Parameter (Mandatory = $true, ParameterSetName = "JsonExample",
        HelpMessage           = 'File name for json example')]
        [string]$JsonFile
    )
    
     # $JsonExample.is present
     if ($JsonExample.IsPresent ){
        $loopNum = 0
        $scripts = @{}
        do {
            $loopNum = $loopNum +1
            $ScriptsData   = (@{ 
                ScriptName = 'name'
                FullName   = 'c:\path\script.ps1';
                Note       = 'Optional: Note aboue script'
                Hash       = 'Optional: get-filehash'
                Restart    = 'true/flase trigger restart after script'
                Enable     = 'true/false'
                Error      = 'false'
            })
            $scripts.add("$loopNum",$ScriptsData)       
        } until ( $loopNum -eq 3)
    
        $SettingsArray = @{}
        $SettingsData  = @{
            ScriptsTotal     = 'enter total number of scripts';
            ScriptsCount     = 1;
            RestartPauseSecs = 30;
            Schedule         = 'false'
            StartupDelayMins = "PT3M";
            SchDuration      = 8;
            ErrorsCount      = 0; 
            Vaildate         = 'false'
            Note             = 'Optional'     
        }
        $SettingsArray.add("Settings",$SettingsData)   
    
        #Combine $scripts and $SettingsArray
        $ScriptsAndSettings=@{"Scripts"=$orderedscripts;
                             "Settings"= $SettingsArray  
    }
    
    } Else { #End of jsonexample.ispresent parameter set
    
    # Start $ps1folder parameter set
    $Files = (Get-childItem -file $PS1Folder -Filter *.ps1)
    $scripts =@{}
    $loopNum =0
    $Restart = 'false'
    $enable  = 'true'
    
    while ($loopNum -lt $files.count) {
        foreach ($file in $files){
            $loopNum = $loopNum +1
            $hash = ($file | Get-FileHash)
            $ScriptsData   = (@{ 
                ScriptName = $file.name;
                FullName   = $file.fullname;
                Note       = 'Optional'
                Hash       = $hash.hash
                Restart    = $restart
                Enable     = $enable 
                Error      = 'false'
            })
            $scripts.add("$loopNum",$ScriptsData)
        }
    } #End While $loopNum
    
    #Create Settings
    $SettingsArray = @{}
    $SettingsData  = @{
        ScriptsTotal      = $files.count;
        ScriptsCount      = 1;
        RestartPauseSecs  = 30;
        Schedule          = 'true';
        SchDuration       = 8;
        StartupDelayMins  = "PT3M";
        ErrorsCount       = 0;
        Vaildate          = 'false'
        Note              = 'Optional'
    }
        $SettingsArray.add("Settings",$SettingsData)
    } 
    
    #Sort scripts by script number
    $OrderedScripts = [ordered]@{}
    foreach ($item in ($scripts.GetEnumerator() | Sort-Object -Property Key)){
        $OrderedScripts[$item.key] = $item.Value
    }
    $OrderedScripts
    
    #Combine $scripts and $SettingsArray
    $ScriptsAndSettings=@{"Scripts"=$orderedscripts;
                        "Settings"= $SettingsArray                  
    } 
    
    #Checking for json path and filename
   If ($JsonExample.IsPresent){
        
   } else{
        $JsonPath = $ps1folder        
        $jsonfile = "PS1SequentialAdvTask.json"
      
   }
 
 #Create Json File from $ScriptsAndSettings 
 write-verbose "$jsonpath\$jsonfile was created"
 $ScriptsAndSettings | ConvertTo-Json | Out-File "$JsonPath\$JsonFile" -Force
    
 } #***** End new-sequentialadvtask *****

function Start-PS1SequentialAdvTask{
<#
.SYNOPSIS
    Starts a sequential series of scripts.ps1. Scripts are controlled by a json file.
    Use New-PS1SequentailAdvTask to create json file (or create manually).
    The order of scripts controlled by number, not position in json file.     
    Error messages are saved back to json file. 
    Enable or disable any script with Json file (Enable = True/False)
    A restart can be triggered after any script (Restart = True/False).
    Restart Delay must be entered in PT Period of Time (Default = PT3M)
    Set a pause before restart (Default = 30secs)
    Any restart before the last script requires Start-PS1SequentailAdvTask to be schedule to run atstartup.

    Example Json file:
    {
  "Scripts": {
    "1": {
      "Restart": "false",
      "FullName": "D:\\test\\test2\\1test.ps1",
      "Error": "false",
      "ScriptName": "1test.ps1",
      "Hash": "1472B042DA35B48C2C61E4683967E7397E8C20853AC966A685D07E692107DA89",
      "Enable": "true",
      "Note": "Optional"
    },
    "2": {
      "Restart": "false",
      "FullName": "D:\\test\\test2\\2test.ps1",
      "Error": "false",
      "ScriptName": "2test.ps1",
      "Hash": "801EC43AAFBB1A514EF347CB36E4E60DEDC7DD02C527499D3B6D09D734727158",
      "Enable": "true",
      "Note": "Optional"
    }
  },
  "Settings": {
    "Settings": {
      "ScriptsCount": 1,
      "ScriptsTotal": 2,
      "Note": "Optional",
      "Schedule": "true",
      "Vaildate": "false",
      "RestartPauseSecs": 30,
      "StartupDelayMins": "PT3M",
      "ErrorsCount": 1
    }
  }
}
   
.PARAMETER JsonTask
    Full path and name of Json control file. 

.EXAMPLE
    Start-PS1SequentialAdvTask -JsonTask c:\users\localadmin\PS1Scripts\PS1SequentialAdvTask.json 

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,
    HelpMessage="Location of json file. Use full path, name, & extension .")]
    [String]$JsonTask
)

#Get content from Jsontask
Write-Verbose "Getting $JsonTask content"
$Task = (get-content -Raw -path $JsonTask | ConvertFrom-Json)

#Settings
$Settings               = $Task.settings.settings
$ScriptsTotal           = $Settings.ScriptsTotal
$ScriptsCount           = $Settings.ScriptsCount
$ErrorsCount            = $Settings.ErrorsCount
$RestartPauseSecs       = $Settings.RestartPauseSecs
$StartupDelayMins       = $Settings.StartupDelayMins
$Schedule               = $Settings.Schedule
$SchDuration            = $settings.SchDuration
$Restart                = 'false'   
$Scripts                = $Task.Scripts
$Vaildate               = $settings.vaildate
Write-Verbose "*****Begining Counts*****"
Write-Verbose "Errors Count  = $ErrorsCount"
write-Verbose "Scripts Count = $ScriptsCount"
Write-Verbose "Scripts Total = $ScriptsTotal"

# Create and schedule script to run start-ps1sequentialadvtask 
# This script will only work if PS1SequentialTask module is installed
if ($Schedule -like "true"){
    Write-Verbose "***** Schedule Enabled *****"
    $CreateSchedule = 'true'

    #Checking for existing scheduledtask
    Write-Verbose "Checking existing scheduledtasks for PS1SequentialAdvTask"
    $ScheduledTasks = (get-scheduledtask -TaskPath \)
    foreach ($ScheduledTask in $ScheduledTasks){
        if ($ScheduledTask.taskname -like "PS1SequentialAdvTask"){         
           Write-Verbose "PS1SequentialAdvTask is already scheduled"
           $CreateSchedule = 'false' 
        }  
    }  #end foreach $scheduledtask in $scheduledtask

    # Create and save script to scheduled      
    # Script will be created in sperate directory, so it is not confused with other scripts to run  
    $JsonTask = "D:\test\test2\PS1SequentialAdvTask.json"
    $ScriptData      = "Start-PS1SequentialAdvTask -jsontask $jsontask"
    $JsonTaskFolder  = (split-path -Path $jsontask)
    $ScriptFolder    = "$JsonTaskFolder\PS1ScheduledAdvTask"   
    $ScriptFullName  = "$ScriptFolder\PS1SequentialAdvTask.ps1" 

    # Checking if directory exists    
    if (-not(test-path -path $ScriptFolder  )) {
         new-item $ScriptFolder -ItemType  Directory
    }
    # Checking if script exists
    If (-not(test-path -path $ScriptFullName -PathType leaf)) {
       new-item  $ScriptFullName -ItemType file -Value $ScriptData
    }          

    #Schedule if needed
    If ($CreateSchedule -like 'true'){
        # time until schedule task is deleted after endboundary
        $expireTime  = (New-TimeSpan -Minutes 5)

        #Set task trigger with bondary times, so scheduled task can be auto deleted
        $TaskTrigger               = (New-ScheduledTaskTrigger -atstartup   )
        $TaskTrigger.StartBoundary = [DateTime]::Now.ToString("yyyy-MM-dd'T'HH:mm:ss")
        $TaskTrigger.EndBoundary   = [DateTime]::Now.AddHours($SchDuration).ToString("yyyy-MM-dd'T'HH:mm:ss")
        $TaskTrigger.delay         = $StartupDelayMins       

        #create and schedule task
        $ScheduledTaskName       = 'PS1SequentialAdvTask'
        $Principal               =  (new-scheduledtaskprincipal -userid "LOCALSERVICE" -LogonType ServiceAccount   -RunLevel Highest )
        $ScheduledTaskAction     = (New-ScheduledTaskAction   -execute "C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" `
                                        -Argument  "-ExecutionPolicy Bypass -File $ScriptFullName")   
        $ScheduledTaskSettingSet = (New-ScheduledTaskSettingsSet  -WakeToRun -Compatibility Win8 -DeleteExpiredTaskAfter $expireTime)          
        $ScheduledTask           = (New-ScheduledTask -Principal $Principal -Action $ScheduledTaskAction -Description $ScheduledTaskName `
                                        -Trigger $TaskTrigger -Settings $ScheduledTaskSettingSet )                                  
        Register-ScheduledTask $ScheduledTaskName -InputObject $ScheduledTask 
        Write-Verbose "Scheduled script $ScriptFullName to run atstart for $SchDuration hrs"
        }

} #end create and schedule script to run start-ps1sequentialadvtask

#Run all scripts until finnished 
Write-verbose "On Script# $scriptscount of $scriptstotal"
If ($ScriptsCount -le $ScriptsTotal){
 
    #Run all scripts until restart tiggered
    do { #Restart -like 'true'
      
        try {
            $script = $scripts.$ScriptsCount 
            $scriptfullname = $script.fullname
            Write-Verbose "Trying... $scriptfullname"

            IF ($script.enable -like 'true'){
                Write-Verbose "Checking if $ScriptFullname is enabled"

                If ($Vaildate -like "true"){
                    Write-Verbose "*****Vaildating $scriptfullname hash*****"
                    If( $script.hash -eq (Get-FileHash $scriptfullname).hash){
                        Invoke-Expression $script.FullName 
                    }else{
                        Write-Verbose "Failed Hash Vaildation"
                        $ErrorsCount = $ErrorsCount +1   
                        throw "Failed Vaildation"  
                    }    
                }else{
                    Write-Verbose "*****Running $ScriptFullname*****"
                    Invoke-Expression $ScriptFullname
                } #End of Vaildate is preseent

            }Else {
                Write-Verbose "$ScriptFullname enabled = false"
            } #End of Script was enabled
                              
        }
        catch {
            $Script.error = $_.Exception.Message
            Write-Verbose "$script.error"
            $ErrorsCount = $ErrorsCount +1    
            
        }
        finally {
           $restart = $script.restart
           $ScriptsCount = $scriptscount +1     
        } #End of Try

    } until ( $restart -like 'true' -or $ScriptsCount -gt $Scriptstotal)     
    
} #End if $ScriptsCount -le $ScriptsTotal

#Create and out-put json file
Write-Verbose "*****Ending Counts*****"
Write-Verbose "Errors Count  = $ErrorsCount"
Write-Verbose "Scripts Count = $ScriptsCount"
Write-Verbose "Scripts Total = $ScriptsTotal"

$settings.ScriptsCount = $ScriptsCount
$settings.ErrorsCount  = $ErrorsCount
$settingsarray      =@{"Settings" = $settings}
$ScriptsAndSettings =@{ "Scripts"  = $scripts;
                       "Settings" = $Settingsarray
}

$ScriptsAndSettings | ConvertTo-Json | Out-File $JsonTask

#Checking if restart needed
If($restart -like 'true'){    
    Write-Verbose "Restarting in $RestartPauseSecs"
    Timeout -t $RestartPauseSecs
    Restart-computer -force 
} 

Write-verbose "***** Done ******"

} #***** end function Start-ps1sequentialadvtask *****

function Start-PS1SequentialTask {
 <#
.SYNOPSIS
    Runs a sequential list of scripts. 
    You can enable a restart after the last script.   
.PARAMETER PS1folder
    Folder with scripts.ps1 to run. Scripts will run in ascending file name. Number your script files.
.PARAMETER ErrorFile
    Optional path for error txt file. 
 #>    

    param (
        [Parameter(Mandatory=$true,
        HelpMessage="Folder with scripts.ps1")]
        [String]$PS1Folder,

        [Parameter(Mandatory=$false,
        HelpMessage="Provide path to error.txt file")]
        [String]$ErrorFile,
       
        [Parameter(Mandatory=$false,
        HelpMessage="Enable restart after last script")]
        [Switch]$Restart 
    )

# Get list of scripts.ps1
[System.Collections.ArrayList]$Scripts = (Get-ChildItem -File -Path $PS1Folder -Filter *.ps1)
$ScriptsCount = 0 #ArrayList start at 0
$ScriptsTotal = $scripts.count
[System.Collections.ArrayList]$Scripts  = $Scripts.fullname

Write-Verbose "ScriptsCount = $ScriptsCount"
Write-Verbose "ScriptsTotal = $ScriptsTotal"
Write-Verbose "Scripts to run $Scripts"


    do {
        try {    
            $script = $scripts[$ScriptsCount]
            Write-Verbose "Trying $script"
            #Invoke-Expression $Script
            $script
        }
        catch {  
            If ($ErrorFile.IsPresent){
                Write-Verbose "Error on trying $script"
                $_.Exception.Message | out-file -FilePath $ErrorFile -append -Force 
            }    
            Write-Verbose "Error on trying $Script"
        }
        finally {
             $ScriptsCount = $ScriptsCount +1
             
        }     
    } while ($ScriptsTotal -gt $ScriptsCount)
   
    If ($Restart.IsPresent){
        Write-Verbose "Restarting Computer in 30secs"
        timeout /t  30
        #Restart-computer 
    }       

} #End of start-ps1sequentialtask