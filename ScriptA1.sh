#!/bin/bash
# this script sync the cloud content to the archive server
# Read the foldernames from Arguments
qpath=$1
dpath=$2
#LOG=$0.log
LOG=/opt/fhem/Script.log
# check if fhemcl exists
file=fhemcl.sh
{
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
# use more rsync lines for different folders
rsync -a --delete "${qpath}/S*" "${dpath}"
# set Status in FHEM
bash fhemcl.sh 8083 "set Sicherung SyncEnde"
umount "$qpath"
umount "$dpath"
} >> $LOG 2>&1
