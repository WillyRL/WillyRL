#!/bin/sh

DUMP_DIR="/opt/mysqlbackup"
DB_USER="root"
DB_PASSWORD=""
DB_HOST="127.0.0.1"
DATE_FORMAT="%Y-%m-%d-%H-%M"
GOOGLE_DRIVE_FOLDER=""
NOW="$(date +$DATE_FORMAT)"
sql_file="$file_name.sql"
gz_file="$file_name.tar.gz"

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
FTP="$(which ftp)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GDRIVE="$(which gdrive)"

mkdir -p $DUMP_DIR/$NOW
cd $DUMP_DIR

echo "BACKUP Starting Now"
### Get all databases name ###
DBS="$($MYSQL -u $DB_USER -h $DB_HOST -p$DB_PASSWORD -Bse 'show databases')"
for db in $DBS
do
  FILE=$DUMP_DIR/$NOW/$db.sql.gz
  echo $db; $MYSQLDUMP --single-transaction --routines --quick -u $DB_USER -h $DB_HOST -p$DB_PASSWORD $db | $GZIP -9 > $FILE
done

ARCHIVE=$NOW.tar.gz
ARCHIVED=$NOW

$TAR -cvf $ARCHIVE $ARCHIVED
$GDRIVE upload --parent $GOOGLE_DRIVE_FOLDER $ARCHIVE
echo "Backup Uploaded to Google Drive"
rm -rf $ARCHIVE
rm -rf $ARCHIVED
echo "Backup Done"
