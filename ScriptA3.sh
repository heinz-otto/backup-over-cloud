#!/bin/bash
# this script will sync the changes back to the cloud,
# normally it will delete files wich are moved and deleted inside the powershell script
# needs fhemcl.sh in the same path
# read foldernames from Arguments
qpath=$1
dpath=$2
LOG=/opt/fhem/Script.log
# check if fhemcl exists
file=fhemcl.sh
if [ ! -e $file ]
then
    echo "$file is missing"  >> $LOG 2>&1
    wget https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file  >> $LOG 2>&1
    chmod +x $file  >> $LOG 2>&1
fi
# sync, umount and trigger
mount $qpath >> $LOG 2>&1
mount $dpath >> $LOG 2>&1
# S* will copy all files and folders with S, folders will be created in $dpath if not exist
# use more rsync lines for different folders
rsync -a --delete ${qpath}/S* ${dpath} >> $LOG 2>&1
umount $qpath >> $LOG 2>&1
umount $dpath >> $LOG 2>&1
# set Status in FHEM
bash fhemcl.sh 8083 "set Sicherung beendet" >> $LOG 2>&1
