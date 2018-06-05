#replace all spaces with underscores recursively
find . -depth -name '* *' -execdir rename 's/ /_/g' {} +

#prefix the ones in  root with 000 to ensure they are executed first
for rootfile in *.sql
do
 mv $rootfile $(echo "000"$rootfile)
done

#flatten folder structure to a single folder
for filepath in $(find -mindepth 2 -type f -name "*.sql")
do
 #replace / with _ (except ./ at start of path. hence temporary token §
 oldfilename=$(echo $filepath | cut -c 3-)
 newfilename=$(echo $oldfilename | sed 's/\//_/g') 
 mv $oldfilename $newfilename
done

rm -r */

