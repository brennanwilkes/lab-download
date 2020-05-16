#!/bin/sh

#Script for distributing rubric files

#Run by using ./rubric-copy.sh OUTPUT_PATH RUBRIC_FILE

#OUTPUT_PATH is the folder which contains the student submission folders.
#ex. ~/Desktop/ta/lab-01/unmarked/

#RUBRIC_FILE is the path to the rubric text file you want copied

#Brennan Wilkes


#Usage message
script_name=$( echo -n "$0" | grep -o '[^/]*$' )
[ "$#" -lt 2 ] && {
	echo "Invalid usage format"
	echo "usage: $script_name OUTPUT_PATH RUBRIC_FILE"
	exit 1
}

#Parse lab/assignment number/name
rubric="$2"
[ ! -f "$rubric" ] && {
	echo "Invalid rubric name $rubric"
	exit 1
} || {
	rubric_data=$( cat "$rubric" )
}

#destination output folder
destination_folder="$1"
[ ! -d "$destination_folder" ] && {
	echo "Invalid destination folder $destination_folder"
	exit 1
}

cd "$destination_folder"

#Iterate over every student folder
find . -mindepth 1 -maxdepth 1 -type d -print | while IFS= read -r  student; do

	cd "$student"
	touch "rubric.txt"
	echo "$( echo -n "$student" | sed 's/\.\///' )" > "rubric.txt"
	echo "" >> "rubric.txt"
	echo "$rubric_data" >> "rubric.txt"

	#Exit to main directory
	cd ..

done

exit 0
