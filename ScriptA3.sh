#!/bin/bash
# this script will sync the changes back to the cloud, 
# normally it will delete files wich are moved and deleted inside the powershell script
# needs fhemcl.sh in the same path
# read foldernames from Arguments
qpath=$1
dpath=$2
# detect the path from this script
sdir=$(dirname $(realpath "$0"))
# sync, umount and trigger
# S* will copy all files and folders with S, folders will be created in $dpath if not exist
# use more rsync lines for different folders
rsync -a --delete ${qpath}/S* ${dpath}
umount $qpath
umount $dpath
# set Status in FHEM
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung beendet" > /dev/null 2>&1
