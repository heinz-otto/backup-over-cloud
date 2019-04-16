#!/bin/bash
# this script will sync the changes back to the cloud,
# normally it will delete files wich are moved and deleted inside the powershell script
# needs fhemcl.sh in the same path
# read foldernames from Arguments
qpath=$1
dpath=$2
# detect the path from this script
sdir=$(dirname $(realpath "$0"))
LOG=/opt/fhem/Script.log
# sync, umount and trigger
mount $qpath >> $LOG 2>&1
mount $dpath >> $LOG 2>&1
# S* will copy all files and folders with S, folders will be created in $dpath if not exist
# use more rsync lines for different folders
rsync -a --delete ${qpath}/S* ${dpath} >> $LOG 2>&1
umount $qpath >> $LOG 2>&1
umount $dpath >> $LOG 2>&1
# set Status in FHEM
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung beendet" >> $LOG 2>&1
