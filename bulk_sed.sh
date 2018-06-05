#usage strip_schema.sh input_dir output_dir
mkdir $2
IFS=$'\0'
while IFS= read -r -d '' p; do
 filename=$2/$(basename $p)
 echo $filename
 #cat $p  | sed 's/\-\-.*//g;s/search_path.*;//g;s/the_schema.*;//g;s/ndoh_stock_002\.//g;s/zambia__svs_001\.//g' > $filename
 cat $p  | sed $3 > $filename 
done < <(find $1/ -type f -name "*.sql" -print0 | sort -z)
