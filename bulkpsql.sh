#set the password for the session using PGPASSWORD=<your password here>
export PGOPTIONS="-c search_path=aj_svs_15_001"
find -type f -name "*.sql" | sort > sql_files 
while read p; do
  psql -U 27795341288 -d helium-app-1 -w -f "$p" >>output
done < sql_files
