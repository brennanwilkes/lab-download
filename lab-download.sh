#!/bin/sh

#Script for downloading and formatting lab submissions

#Brennan Wilkes

#Dependency check
unzip -v 2>/dev/null >/dev/null
[ $? -ne 0 ] && {
	echo "Please install dependency unzip.

	sudo apt-get install unzip
	"
	exit 2
};

[ "$#" -lt 1 ] && {
	echo "usage: $script_name ZIP_FILE_PATH"
	exit 1
}

rename_entry(){
	echo "got $1"
}

script_name=$( echo -n "$0" | grep -o '[^/]*$' )
destination_folder="~/Desktop/cpsc1160-ta/"
zipfile="$1"
lab_number=$( echo -n "$zipfile" | grep -o '^.*Download' | sed 's/ Download//' | sed 's/ /-/' | tr '[:upper:]' '[:lower:]')
eval lab_folder=$( echo -n "$destination_folder/$lab_number/" | tr -s '/')

mkdir "$lab_folder" 2>/dev/null

rm -rf $lab_folder*

unzip -q "$zipfile" -d "$lab_folder"

cd "$lab_folder"

rm "index.html"

mv *Pham* "97885-96739 - H'ong Pham - May 12, 2020 744 PM - Lab1-100271972.zip"
mv *Wesley* "58278-96739 - Wes-ley Ng - May 13, 2020 1056 AM - lab1.zip"


#57006-96739 - Erik Dengler - May 6, 2020 231 PM - Lab-One.zip
#57006-96739\x00Erik Dengler\x00May 6, 2020 231 PM\x00Lab-One.zip

find . -type f -print | while IFS= read -r  file; do
	name=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f2 | tr ' ' '-' )
	date=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f3 )
	extension=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f4 | grep -o '\.[^.]*$')

	mkdir "$name" 2>/dev/null

	mv "$file" "$name/$date$extension"

done
