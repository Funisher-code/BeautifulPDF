#!/bin/sh

#![Login Button](pathToFile)

#![[pathToFile]]

tmpDir="tmpWikiLinks"
pwd=$(pwd)

function replaceWikilinksWithMD () {
	IFS=$'\n' read -d '' -r -a strSearch < $tmpDir/searchStrings.txt
	echo "search for: ${strSearch[@]}"

	IFS=$'\n' read -d '' -r -a strReplace < $tmpDir/replaceStrings.txt
	echo "\nreplace with: ${strReplace[@]}\n"

	cp "$inFile" "$inFile.conv.md"

	#read -p "Press any key to start conversion..." -n1 -s

	length=${#strSearch[@]}
	for (( j=0; j<length; j++ ));
	do
		echo "> sed -i '.original' -e 's|${strSearch[$j]}|${strReplace[$j]}|g' $inFile.conv.md"
		sed -i '.original' -e "s|${strSearch[$j]}|${strReplace[$j]}|g" $inFile.conv.md
	done	
}

function findFullPaths () {
	while read line
	do 
		find . -name "$line" >> "$tmpDir/wikiLinkFullPaths.txt"
	done < "$tmpDir/wikiLinkNames.txt"
}

function extractWikiLinks () {
	mkdir "$tmpDir"
	cat "$inFile" | grep "\!\[\[" | cut -d "[" -f 3 | cut -d "]" -f 1 > "$tmpDir/wikiLinkNames.txt"
}

function createSearchStrings () {
	while read line
	do 
		echo "\!\[\[$line\]\]" >> $tmpDir/searchStrings.txt
	done < "$tmpDir/wikiLinkNames.txt"
} 

function createReplaceStrings () {
	while read line
	do 
		echo "\!\[\]($pwd/$line)" >> $tmpDir/replaceStrings.txt
	done < "$tmpDir/wikiLinkFullPaths.txt"
} 


while getopts i:o:a: flag
do
    case "${flag}" in
        i) inFile=${OPTARG};;
        o) outFile=${OPTARG};;
        a) additionalArgs=${OPTARG};;
    esac
done

# extract wiki links
extractWikiLinks

# find each image with full path
findFullPaths

# search and replace
createSearchStrings
createReplaceStrings
replaceWikilinksWithMD

read -p "Press any key to delete temporary files... " -n1 -s
rm -r $tmpDir