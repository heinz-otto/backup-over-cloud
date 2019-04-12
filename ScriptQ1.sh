#!/bin/bash
# needs fhemcl.sh in the same path
# Variables
qpath="/media/zadonixs1"
dpath="/media/magenta"
sdir=$(dirname $(realpath "$0"))
# mount, sync and trigger
mount $qpath
mount $dpath
rsync -rut --inplace ${qpath}/S* ${dpath}
# delete the sourcefiles
rm -r ${qpath}/S*
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung CopyMagentaEnde" > /dev/null 2>&1
umount $qpath
umount $dpath
