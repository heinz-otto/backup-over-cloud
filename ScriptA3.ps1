function ScriptA3 {
#!/bin/bash
# this script will sync the changes back to the cloud,
# normally it will delete files wich are moved and deleted inside the powershell script
# read foldernames from Arguments
param(
$dest,
$qpath,
$dpath
)
$exe='ssh'

$script=@"
qpath=$qpath
dpath=$dpath

"@
$script+=@'
LOG=Script.log
if [ -d "log" ];then LOG="log/$LOG";fi
# sync, umount and trigger
{
mount "$qpath"
mount "$dpath"
# S* will copy all files and folders with S, folders will be created in $dpath if not exist
# use more rsync lines for different folders and set Status in FHEM
if  rsync -a --delete ${qpath}/S* ${dpath}
then
   echo "set Sicherung beendet"|./fhemcl.sh 8083
else
   echo "set Sicherung ERROR_A3"|./fhemcl.sh 8083
fi
umount "$qpath"
umount "$dpath"
} >> $LOG 2>&1
'@
& $exe $dest $script.replace("`r`n","`n")
}
