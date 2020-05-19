#!/bin/sh

#Script for auto formatting rubric raw text
#Nicely combined with rubric-copy.sh to setup a text based marking rubric for every student

#To use: First copy and paste the raw text of the assignment rubric from d2l into a file.
#Then run by using ./rubric-autoformat.sh RUBRIC_FILE

#RUBRIC_FILE is the path to the rubric text file you want formatted

#Brennan Wilkes

#Usage message
script_name=$( echo -n "$0" | grep -o '[^/]*$' )
[ "$#" -lt 1 ] && {
	echo "Invalid usage format"
	echo "usage: $script_name RUBRIC_FILE"
	exit 1
}

#grab rubric file
rubric="$1"
[ ! -f "$rubric" ] && {
	echo "Invalid rubric name $rubric"
	exit 1
} || {

	#Grab rubric data and delete
	rubric_data=$( cat "$rubric" )
	echo -n '' > "$rubric"
}


#Preform trimming ^\/ [0-9]+$

#filter for lines that start with backslash space number.
#Grab previous line of context
#Then add linebreak separators
echo "$rubric_data" | grep --no-group-separator -E -B 1 '^\/ [0-9]+$' | sed '/^[^/]/i \\x00' | tr -d '\0' >> "$rubric"

exit 0
