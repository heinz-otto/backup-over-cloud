<#
.SYNOPSIS
    This Script register a Task in Taskscheduler Windows
.DESCRIPTION
    The Task will registered with User Account logged on, without save Password
.EXAMPLE
    no Arguments
.NOTES
    it's important to capsulate the Script in argument with ""
    The Logontype is independend from user Logon (S4U)
    Password is not needed and not saved or asked
    There are two triggers
#>
$triggers = @()
$triggers += New-ScheduledTaskTrigger -Daily -At 08:00 
$triggers += New-ScheduledTaskTrigger -AtStartup

$action = New-ScheduledTaskAction -WorkingDirectory c:\Tools\Scripts -Execute powershell.exe -Argument '-noninteractive -command "&{C:\Tools\Scripts\FolderSyncAblauf.ps1}"'
$principal = New-ScheduledTaskPrincipal -UserID "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Limited

Register-ScheduledTask -TaskName MoveCloudToArchiv –Action $action –Trigger $triggers –Principal $principal

# Unregister-ScheduledTask -TaskName MoveCloudToArchiv
