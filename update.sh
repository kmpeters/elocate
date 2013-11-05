#!/bin/bash

#
#!DB_DIR=/home/oxygen/KPETERSN/development/elocate/db
DB_DIR=/net/s100dserv/xorApps/elocate/db
#
APSMASTER=/net/xmaster/export/APSmaster/gateway/epics
APSSHARE=/net/s100dserv/APSshare/epics

IGNORE_DIRS=`cat $DB_DIR/ignoreDirs | tr '\n' ' '`

db_files=()

### APSmaster
if [ -e $APSMASTER ]
then
  echo "Updating database for APSmaster"
  updatedb -l 0 -o $DB_DIR/APSmaster -n "$IGNORE_DIRS" -U $APSMASTER
  db_files+=("$DB_DIR/APSmaster")
fi

### APSshare
if [ -e $APSSHARE ]
then
  echo "Updating database for APSshare"
  updatedb -l 0 -o $DB_DIR/APSshare -n "$IGNORE_DIRS" -U $APSSHARE
  db_files+=("$DB_DIR/APSshare")
fi

### dservs
for i in {1..35} 100
do
  DSV=s"$i"dserv
  PTH=/net/"$DSV"/xorApps/epics
  if [ -e $PTH ]
  then
    echo "Updating database for $DSV"
    #!echo "updatedb -l 0 -o $DB_DIR/$DSV -n \"\$IGNORE_DIRS\" -U $PTH"
    updatedb -l 0 -o $DB_DIR/$DSV -n "$IGNORE_DIRS" -U $PTH
    db_files+=("$DB_DIR/$DSV")
  fi 
done

### Make note of last update time
date > $DB_DIR/lastUpdateTime
### Save list of databases that were updated
echo "${db_files[@]}" > $DB_DIR/lastUpdateList
