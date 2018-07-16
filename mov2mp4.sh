find ./ -type f -iname "*.mov" | while read f
    do ffmpeg -i "$f" -c copy "${f%.*}.mp4" < /dev/null
done
