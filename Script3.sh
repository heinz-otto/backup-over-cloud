#!/bin/bash
# needs fhemcl.sh in the same path
# Variables
qpath="/media/ds1"
dpath="/media/m"
sdir=$(dirname $(realpath $0))
# sync, umount and trigger
rsync -a --delete "${qpath}/Sicherung/" "${dpath}/Sicherung/"
rsync -a --delete "${qpath}/Scripts/" "${dpath}/Scripts/"
umount $qpath
umount $dpath
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung beendet" > /dev/null 2>&1
