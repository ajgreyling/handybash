#!/bin/bash
timestamp=$(date +"%Y%m%d%H%M")
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_file=""
verbose=0

db_user_source=$1
db_user_target=$2
db_pass_source=$3
db_pass_target=$4
schema_source=$5
schema_target=$6
host_source=$7
host_target=$8

echo backing up source...
export PGPASSWORD="$db_pass_source"

#contains -s (Schema Only) below for quicker testing times. Remove before using!
pg_dump -U $db_user_source -w -n $schema_source -h $host_source -x -T "$schema_source.__*" -c helium > $schema_source.$timestamp.sql

echo create restore file with new schema name...
cat $schema_source.$timestamp.sql | sed "s/$schema_source/$schema_target/g" > $schema_target.$timestamp.sql

echo restoring to target...
export PGPASSWORD="$db_pass_target"
psql -U $db_user_target -h $host_target -w helium-app-1 -f $schema_target.$timestamp.sql > $schema_target.$timestamp.log 2>&1

echo setting permissions...
psql -U $db_user_target -h $host_target -w helium-app-1 -c "alter schema $schema_target owner to admin_$schema_target;" >> $schema_target.$timestamp.log 2>&1
psql -U $db_user_target -h $host_target -w helium-app-1 -c "grant select,insert,update,delete,truncate ON ALL TABLES IN SCHEMA $schema_target TO writer_$schema_target;" >> $schema_target.$timestamp.log 2>&1
psql -U $db_user_target -h $host_target -w helium-app-1 -c "grant select ON ALL TABLES IN SCHEMA $schema_target TO reader_$schema_target;" >> $schema_target.$timestamp.log 2>&1
psql -U $db_user_target -h $host_target -w helium-app-1 -c "grant select,insert,update,delete,truncate,references,trigger ON ALL TABLES IN SCHEMA $schema_target TO admin_$schema_target;" >> $schema_target.$timestamp.log 2>&1

rm $schema_source.$timestamp.sql
rm $schema_target.$timestamp.sql
#clear password
export PGPASSWORD=""

#psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME"
echo done!  
echo please delete $schema_target.$timestamp.log when you are done

