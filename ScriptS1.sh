#!/bin/bash
# needs fhemcl.sh in the same path
# read Foldernames from Arguments
qpath=$1
dpath=$2
#LOG=$0.log
LOG=/opt/fhem/ScriptS1.log
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
# if rsync ist ok then remove the synced files at source
if ! rsync -rut --inplace "${qpath}/S*" "${dpath}"
then
   rm -r "${qpath}/S*"
fi
# cp -pRu "${qpath}/S*" "${dpath}"
bash fhemcl.sh 8083 "set Sicherung CopyMagentaEnde"
umount "$qpath"
umount "$dpath" 
} >> $LOG 2>&1
