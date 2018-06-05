> combined

IFS=$'\0'

while IFS= read -r -d '' p; do
 cat $p >> combined
done < <(find -type f -name "*.sql" -print0 | sort -z)

rm -f combined.sql
mv combined combined.sql
