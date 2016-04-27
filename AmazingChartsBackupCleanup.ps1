#Amazing Charts, Remove Old backup files.
#FrankTucker@lan-sol.com
#AC runs a daily backup to program folder (Cannot Change). The backup file can be large, 25GB Plus.
#Only remove files if more than 7 total backup files AND the backup from yesturday is compelete. 
#Removes backups 8 days and older

#Dates
$Date = Get-Date
$LastWeek = ($date.AddDays(-7))
$Yesturday = ($date.AddDays(-1))

#Amazing Charts Backup Folder
$BackupFolder  = ('C:\Program Files (x86)\Amazing Charts\Backup\')
Set-Location $BackupFolder


#File enc Backup files older then 7 Days
$oldfiles = 0,0
$oldfiles = (Get-ChildItem -Path $BackupFolder -Filter *enc | Where-Object -Property CreationTime -LT $LastWeek)

#Lenghth and Sum/Size of all enc backup files
$TotalBackupInfo = (Get-ChildItem -Path $BackupFolder -Filter *enc | measure -Property Length -sum )

#Length and Sum/Size of yesturday backup file
$YesturdayBackupInfo = ( Get-ChildItem -Path $BackupFolder -Filter *enc | where-Object -Property CreationTime -GT $yesturday | measure -Property Length -sum )


#Check the number and Sum/Size of backup files, remove files older than 7 days if sum and number are correct.

if ($YesturdayBackupInfo.Sum -gt 26000000000 -and $TotalBackupInfo.Count -gt 7 -and $TotalBackupInfo.sum -gt 182000000000)
{
   
 remove-item $oldfiles -force
      
}






