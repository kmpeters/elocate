#!/bin/bash

# runs as cron job under epicsadm account from gov.aps.anl.gov
# crontab -e
# Update elocate databases
#   30 05 * * * /net/s100dserv/xorApps/elocate/update.sh > /dev/null 2>&1
#
#              field          allowed values
#              -----          --------------
#              minute         0-59
#              hour           0-23
#              day of month   1-31
#              month          1-12 (or names, see below)
#              day of week    0-7 (0 or 7 is Sun, or use names)
#
#

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
for i in {1..35} 100 11bm
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
