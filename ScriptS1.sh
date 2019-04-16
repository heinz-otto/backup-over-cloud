#!/bin/bash
# needs fhemcl.sh in the same path
# read Foldernames from Arguments
qpath=$1
dpath=$2
#LOG=$0.log
LOG=/opt/fhem/ScriptS1.log
# check if fhemcl exists
file=fhemcl.sh
if [ ! -e $file ]
then
    echo "$file is missing"  >> $LOG 2>&1
    wget https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file  >> $LOG 2>&1
    chmod +x $file  >> $LOG 2>&1
fi
# mount, sync and trigger
mount $qpath >> $LOG 2>&1
mount $dpath >> $LOG 2>&1
rsync -rut --inplace ${qpath}/S* ${dpath} >> $LOG 2>&1
# delete the sourcefiles
if [ $? -eq 0 ]; then
   rm -r ${qpath}/S* >> $LOG 2>&1
fi
# cp -pRu "${qpath}/S*" "${dpath}"
bash fhemcl.sh 8083 "set Sicherung CopyMagentaEnde" >> $LOG 2>&1
umount $qpath >> $LOG 2>&1
umount $dpath >> $LOG 2>&1
