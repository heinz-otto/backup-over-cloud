#!/bin/bash
# needs fhemcl.sh in the same path
# read Foldernames from Arguments
qpath=$1
dpath=$2
sdir=$(dirname $(realpath "$0"))
LOG=$0.log
# mount, sync and trigger
mount $qpath
mount $dpath
rsync -rut --inplace ${qpath}/S* ${dpath} >> $LOG 2>&1
# delete the sourcefiles
if [ $? -eq 0 ]; then
   rm -r ${qpath}/S*
fi
# cp -pRu "${qpath}/S*" "${dpath}"
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung CopyMagentaEnde" > /dev/null 2>&1
umount $qpath
umount $dpath
