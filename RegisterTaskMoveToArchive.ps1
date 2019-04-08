$triggers = @()
$triggers += New-ScheduledTaskTrigger -Daily -At 08:00 
$triggers += New-ScheduledTaskTrigger -AtStartup

$action = New-ScheduledTaskAction -WorkingDirectory c:\Tools\Scripts -Execute powershell.exe -Argument "-noninteractive -command '&{C:\Tools\Scripts\FolderSyncAblauf.ps1}'"
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType S4U -RunLevel Highest

Register-ScheduledTask -TaskName MoveCloudToArchiv –Action $action –Trigger $triggers –Principal $principal
