#!/bin/sh

#Script for downloading and formatting lab submissions

#Run by using ./lab-download.sh OUTPUT_PATH ZIP_FILE_PATH

#OUTPUT_PATH is the folder you would like to output the submissions to.
#The script will then create a sub folder, so outputing to ~/Desktop/ is a good choice.

#ZIP_FILE_PATH is the path to the downloaded zip file from d2l brightspace. *NOTE*, do
#not change the file name of the zip, as it contains meta data required for this script_name
#to properly format the submissions. The zip will not be deleted, in case of script failure.

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
[ "$lab_number" = "" ] || [ "$lab_number" = " " ] && {
	echo "Invalid zip file name. Please do not rename the zip file. Leave it as downloaded from d2l brightspace"
	exit 1
}

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

	#exit back to main directory
	cd ..
done

#Iterate over every student folder
find . -mindepth 1 -maxdepth 1 -type d -print | while IFS= read -r  student; do

	#Enter student folder
	cd "$student"

	#Grab submission name and extension type
	fn=$( ls )
	extension=$( ls | grep -o '\.[^.]*$' )

	#unzip zip file submissions and remove archive
	[ "$extension" = ".zip" ] && {
		unzip -q "$fn"
		rm "$fn"
	} || {

		#Rename non-zip files to student name
		mv "$fn" "$( echo -n "$student" | sed 's/\.\///' )$extension"
	}

	#Exit to main directory
	cd ..
done

exit 0
