#!/bin/bash
# this script sync the cloud content to the archive server
# needs fhemcl.sh in the same path
# Read the foldernames from Arguments
qpath=$1
dpath=$2 
# detect the path from this script
sdir=$(dirname $(realpath "$0")) 
# mount, sync and trigger
mount $qpath
mount $dpath
# S* will copy all files and folders with S, folders will be created in $dpath if not exist
# use more rsync lines for different folders
rsync -a --delete ${qpath}/S* ${dpath}
# set Status in FHEM
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung SyncEnde" > /dev/null 2>&1
