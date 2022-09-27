#!/bin/bash

shopt -s expand_aliases
alias fzf="fzf +m --reverse"

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

#Grab the urls and titles
urls=$(awk '$2 ~ /https/ {print $2}' <<< $output)
titles=$(awk '$2 ~ /https/ {for(i=3;i<=15;i++)if($i=="class=" || $i=="class=fade"){break;} else {printf $i" "};print ""}' <<< $output)
vals=$(paste <(printf "%s\n" "${urls[@]}") <(printf "%s\n" "${titles[@]}"))

while true; do
    #Create interavtive list of urls to select from
    choose=$(echo -e "$vals" | sed -e 's/title=//' | sort | uniq | fzf)
    pick=$(awk '{print $1}' <<< $choose)
    
    #If no choice made exit out and clean up
    [ -z "$pick" ] && clear && exit 1

    #Play video at urls
    mpv "$pick"
    clear
done
