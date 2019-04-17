#!/bin/bash
# this script sync the cloud content to the archive server
# Read the foldernames from Arguments
# logging will be done in the actual path 
qpath=$1
dpath=$2
LOG=$0.log
# check if fhemcl exists in the actual path
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
# set Status in FHEM
# use more rsync lines for different folders 
if rsync -a --delete ${qpath}/S* ${dpath}
then
   bash fhemcl.sh 8083 "set Sicherung SyncEnde"
else
   bash fhemcl.sh 8083 "set Sicherung ERROR_A1"
fi
umount "$qpath"
umount "$dpath"
} >> $LOG 2>&1
