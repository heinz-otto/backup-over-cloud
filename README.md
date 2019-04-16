# backup-over-cloud
Transport a daily backup pieces over a cloud drive to a second location. The Files should be well prepared: zipped and encrypted! In my Environment, backup program will be the files provided in a Folder named d:\Magenta\Sicherung in the source location. The files will be transported to the archive location in the Folder D:\Sicherung. The Files will be "moved" over the cloud: After a working day, the backup ist done and the files will be copied to the cloud. Next morning, the files will be archived and online deleted. 

Location S(ource)

On the Windows Server, Powershell Script CopyMagenta.ps1 is startet
On the Linux Box, after the Powershell Script is finished, the Bash Script ScriptS1.sh is startet 

Location A(rchive)

On the Windows Server, Powershell Script FolderSyncAblauf.ps1 is startet. This will sending a trigger only and wait first.
On the Linux Box, if the trigger is received, the ScriptA1.sh ist startet. 
On the Windows Server, the Script will continue after A1 is finished.
On the Linux Box, if the Powershell finished trigger is received, the ScriptA3.sh ist startet.
