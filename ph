#!/bin/bash

#Prompt user for search query
echo -n "Search: "
read -r query

#Make sure they gave an input
[ -z "$query" ] && echo "No Input Given" && exit 1

base_addr="https://www.pornhub.com/"
search_string="video/search?search="

#Deal with different seperaters
query=$(sed -e 's/+/%2B/g' -e 's/#/%23/g' -e 's/&/%26/g' -e 's/ /+/g' <<< $query)

#Pull the html of site silently
dump_html=$(curl -s ${base_addr}${search_string}${query})

#Pull only the lines that are relevent
output=$(grep "view_video.php?viewkey=" <<< $dump_html | sed 's/href=//g' | sed 's/"//g' | sed 's/\/view_/https:\/\/www.pornhub.com\/view_/g')

#Grab the urls
urls=$(awk '$2 ~ /https/ {print $2}' <<< $output)

while true; do
	#Create interavtive list of urls to select from
	choose=$(echo -e "$urls" | sort | uniq | fzf)

	#If no choice made exit out and clean up
	[ -z "$choose" ] && clear && exit 1

	#Play video at urls
	mpv "$choose"
	clear
done
