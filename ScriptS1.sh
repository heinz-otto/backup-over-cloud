#!/bin/bash
# This Script will being copy folders from a local Server to a Cloud Drive
# if success, the folders will be removed from the source
# read Foldernames from Arguments
qpath=$1
dpath=$2
#LOG=$0.log
LOG=Script.log
if [ -d "log" ];then LOG="log/$LOG";fi
# check if fhemcl exists
file=fhemcl.sh
{
Date
if [ ! -e $file ]
then
    echo "$file is missing"
    wget https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file
    chmod +x $file
fi
# mount, sync and trigger
mount "$qpath"
mount "$dpath"
# if rsync ist ok then remove the synced files at source, set status in fhem
if rsync -rut --inplace ${qpath}/S* ${dpath}
then
   rm -r "${qpath}/S*"
   bash fhemcl.sh 8083 "set Sicherung CopyMagentaEnde"
else
   bash fhemcl.sh 8083 "set Sicherung ERROR_S1"
fi
umount "$qpath"
umount "$dpath" 
} >> $LOG 2>&1
