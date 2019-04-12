#!/bin/bash
# needs fhemcl.sh in the same path
# Variables, fill in the right foldernames
qpath="/media/ds1"
dpath="/media/m"
sdir=$(dirname $(realpath "$0"))
# mount, sync and trigger
mount $qpath
mount $dpath
rsync -rutv --inplace ${qpath}/S* ${dpath}
# cp -pRu "${qpath}/S*" "${dpath}"
# bash "${sdir}/fhemcl.sh" 8083 "set Sicherung SyncEnde" > /dev/null 2>&1
umount $qpath
umount $dpath
