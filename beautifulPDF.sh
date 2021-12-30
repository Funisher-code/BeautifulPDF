#!/bin/sh

# prerequesite: proper markdown links, no wiki links
#--------------------------------------------------------------------
# Parameters
#--------------------------------------------------------------------

dpi=254
tmpDir="tmpBeautifulPDF"

#--------------------------------------------------------------------
printColored 1 "# prerequesite: proper markdown links, no wiki links"
printColored 2 "# parse flags"

while getopts i:o:a: flag
do
    case "${flag}" in
        i) inFile=${OPTARG};;
        o) outFile=${OPTARG};;
        a) additionalArgs=${OPTARG};;
    esac
done

printColored 3 "input File: $inFile"
printColored 3 "output PDF: $outFile"
printColored 3 "additional arguments for pandoc: $additionalArgs"

#--------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------
printColored () {
	echo "$(tput setaf $1)$2$(tput sgr0)"
}

readFlags () {
	while getopts i:o:a: flag
	do
	    case "${flag}" in
	        i) global inFile=${OPTARG};;
	        o) global outFile=${OPTARG};;
	        a) global additionalArgs=${OPTARG};;
	    esac
	done
}

initTmpFolder () {
	echo "> mkdir $tmpDir"
	mkdir $tmpDir
	echo "> cp "$inFile" "$tmpDir/""
	cp "$inFile" "$tmpDir/"
}

grepImageLines () {
	echo "> cat $inFile | grep "\!\[" > $tmpDir/imageLines.txt"
	cat $inFile | grep "\!\[" > $tmpDir/imageLines.txt
}

extractImagePaths () {
	echo 'cat $tmpDir/imageLines.txt | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d "?" -f 1 | cut -d ":" -f 2 > $tmpDir/imageFullPath.txt'
	cat $tmpDir/imageLines.txt | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d "?" -f 1 | cut -d ":" -f 2 > $tmpDir/imageFullPath.txt
	echo 'cat $tmpDir/imageLines.txt | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d "?" -f 1 > $tmpDir/imageSearch.txt'
	cat $tmpDir/imageLines.txt | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d "?" -f 1 > $tmpDir/imageSearch.txt
	echo 'cat $tmpDir/imageLines.txt | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d "?" -f 1 | cut -d ":" -f 2 | sed 's|.*/||' > $tmpDir/imageName.txt'
	cat $tmpDir/imageLines.txt | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d "?" -f 1 | cut -d ":" -f 2 | sed 's|.*/||' > $tmpDir/imageName.txt
}

function copyFilesToFolder () {
	while read line
	do 
		echo "cp $line $tmpDir"
		cp "$line" "$tmpDir"
	done < $tmpDir/imageFullPath.txt
}

function changeDPI() {
	while read line
	do 
		echo "magick convert "$tmpDir/$line" -density $dpi "$tmpDir/$line""
		magick convert "$tmpDir/$line" -density $dpi "$tmpDir/$line"
	done < $tmpDir/imageName.txt	
}

function replaceImageLinks () {
	IFS=$'\n' read -d '' -r -a strSearch < $tmpDir/imageSearch.txt
	#echo "search for: ${strSearch[@]}"

	IFS=$'\n' read -d '' -r -a strReplace < $tmpDir/imageName.txt
	#echo "replace with: ${strReplace[@]}"

	length=${#strSearch[@]}
	for (( j=0; j<length; j++ ));
	do
		echo "> sed -i '.original' -e 's|${strSearch[$j]}|${strReplace[$j]}|g' $tmpDir/$inFile"
		sed -i '.original' -e "s|${strSearch[$j]}|${strReplace[$j]}|g" $tmpDir/$inFile
	done	
}

function createPandocPDF () {
	cd "$tmpDir"
	echo "pandoc -o "$outFile" --from markdown --template eisvogel --listings --number-sections "$tmpDir/$inFile""
	pandoc -o "../$outFile" --from markdown --template eisvogel --listings --number-sections "$inFile"
	cd ..
}

#--------------------------------------------------------------------
# Call Functions
#--------------------------------------------------------------------
printColored 2 "# create temporary folder and copy markdown file there"
initTmpFolder

printColored 2 "# determine included images"
grepImageLines

printColored 2 "# extract image paths and names"
extractImagePaths

printColored 2 "# copy all images to temporary folder"
copyFilesToFolder

printColored 2 "# change pixel density of all images"
changeDPI

printColored 2 "# replace original image links with links to temporary images of correct pixel density ($dpi ppi)"
replaceImageLinks

printColored 2 "# use eisvogel template to create pdf"
createPandocPDF

printColored 1 "# check PDF: $outFile"
read -p "Press any key to delete temporary files... " -n1 -s
rm -r $tmpDir