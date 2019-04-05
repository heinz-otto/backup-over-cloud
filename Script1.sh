#!/bin/bash
# needs fhemcl.sh in the same path
# Variables
qpath="/media/m"
dpath="/media/ds1"
sdir=$(dirname $(realpath $0))
# mount, sync and trigger
mount $qpath
mount $dpath
rsync -a --delete "${qpath}/Sicherung/" "${dpath}/Sicherung/"
rsync -a --delete "${qpath}/Scripts/" "${dpath}/Scripts/"
bash "${sdir}/fhemcl.sh" 8083 "set Sicherung SyncEnde" > /dev/null 2>&1
