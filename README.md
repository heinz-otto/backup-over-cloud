# backup-over-cloud
Transport a backup in daily pieces over a cloud drive to a second location

Location S(ource)

On the Windows Server, Powershell Script CopyMagenta.ps1 is startet
On the Linux Box, after the Powershell Script is finished, the Bash Script ScriptS1.sh is startet 

Location A(rchive)

On the Windows Server, Powershell Script FolderSyncAblauf.ps1 is startet. This will sending a trigger only and wait first.
On the Linux Box, if the trigger is received, the ScriptA1.sh ist startet. 
On the Windows Server, the Script will continue after A1 is finished.
On the Linux Box, if the Powershell finished trigger is received, the ScriptA3.sh ist startet.
