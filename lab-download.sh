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

#Usage message
script_name=$( echo -n "$0" | grep -o '[^/]*$' )
[ "$#" -lt 2 ] && {
	echo "usage: $script_name OUTPUT_PATH ZIP_FILE_PATH"
	exit 1
}

#Parse lab/assignment number/name
zipfile="$2"
#destination output folder
destination_folder="$1"

lab_number=$( echo -n "$zipfile" | grep -o '^.*Download' | sed 's/ Download//' | sed 's/ /-/' | tr '[:upper:]' '[:lower:]')

#Generate output director
eval lab_folder=$( echo -n "$destination_folder/$lab_number/" | tr -s '/')

#create output directory tree
[ -d "$lab_folder" ] || {
	mkdir "$lab_folder"
}
[ -d "${lab_folder}unmarked/" ] || {
	mkdir "${lab_folder}unmarked/"
}
[ -d "${lab_folder}marked/" ] || {
	mkdir "${lab_folder}marked/"
}

#unzip submissions
unzip -q "$zipfile" -d "${lab_folder}unmarked/"

#cd to submissions folder
cd "${lab_folder}unmarked/"

#Remove manifest
rm "index.html"

#Iterate over every submission
find . -type f -print | while IFS= read -r  file; do

	#Parse student name
	name=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f2 | tr ' ' '-' )

	#Parse submission date
	date=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f3 )

	#Parse submission extension
	extension=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f4 | grep -o '\.[^.]*$')

	#Create named folder
	[ -d "$name" ] || {
		mkdir "$name"
	}

	#Move submission into folder and rename to date
	mv "$file" "$name/$date$extension"

	#Enter named folder
	cd "$name"

	#Remove older submissions
	[ $( ls -1 | wc -l ) -gt 1 ] && {
		rm "$( ls -t | tail -n1 )"
	}

	#exit back to main
	cd ..
done

#Iterate over every student folder
find . -mindepth 1 -maxdepth 1 -type d -print | while IFS= read -r  student; do
	cd "$student"

	fn=$( ls )
	extension=$( ls | grep -o '\.[^.]*$' )

	[ "$extension" = ".zip" ] && {
		unzip -q "$fn"
		rm "$fn"
	} || {
		mv "$fn" "$( echo -n "$student" | sed 's/\.\///' )$extension"
	}

	cd ..
done
