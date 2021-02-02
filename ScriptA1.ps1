function ScriptA1 {
#!/bin/bash
# this script sync the cloud content to the archive server
# Read the foldernames from Arguments
# needs fhemcl.sh in the actual path (not the script path)
# logging is done in the actual path too
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
# check if fhemcl exists
file=fhemcl.sh
{
date
if [ ! -e $file ]
then
    echo "$file is missing"
    wget https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file
    chmod +x $file
fi
# mount, sync and trigger
mount "$qpath"
mount "$dpath"
# S* will copy all files and folders with S, folders will be created in $dpath if not exist
# set Status in FHEM
# use more rsync lines for different folders
if rsync -a --delete ${qpath}/S* ${dpath}
then
   echo "set Sicherung SyncEnde"|./fhemcl.sh 8083
else
   echo "set Sicherung ERROR_A1"|./fhemcl.sh 8083
fi
umount "$qpath"
umount "$dpath"
} >> $LOG 2>&1
'@
& $exe $dest $script.replace("`r`n","`n")
}
