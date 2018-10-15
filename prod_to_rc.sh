#!/bin/bash
timestamp=$(date +"%Y%m%d%H%M")

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

pg_dump -U $db_user_source -w -n $schema_source -h $host_source -x -T "$schema_source.__*" -c helium > $timestamp.$schema_source.sql

echo create restore file with new schema name...
cat $timestamp.$schema_source.sql | sed "s/$schema_source/$schema_target/g" > $timestamp.$schema_target.sql

echo restoring to target...
export PGPASSWORD="$db_pass_target"
psql -U $db_user_target -h $host_target -w helium-app-1 -f $timestamp.$schema_target.sql > $timestamp.$schema_target.log 2>&1

echo setting permissions...
psql -U $db_user_target -h $host_target -w helium-app-1 -c \
 "alter schema $schema_target owner to admin_$schema_target;" \
 >> $timestamp.$schema_target.log 2>&1
psql -U $db_user_target -h $host_target -w helium-app-1 -c \
 "grant select,insert,update,delete,truncate ON ALL TABLES IN SCHEMA $schema_target TO writer_$schema_target;" \
 >> $timestamp.$schema_target.log 2>&1
psql -U $db_user_target -h $host_target -w helium-app-1 -c \
 "grant select ON ALL TABLES IN SCHEMA $schema_target TO reader_$schema_target;" \
 >> $timestamp.$schema_target.log 2>&1
psql -U $db_user_target -h $host_target -w helium-app-1 -c \
 "grant select,insert,update,delete,truncate,references,trigger ON ALL TABLES IN SCHEMA $schema_target TO admin_$schema_target;" \
 >> $timestamp.$schema_target.log 2>&1

#rm $timestamp.$schema_source.sql
#rm $timestamp.$schema_target.sql
#clear password
export PGPASSWORD=""

echo done!  
echo please delete $timestamp.$schema_target.log when you are done
