#!/bin/sh

#Script for downloading and formatting lab submissions

#Run by using ./lab-download.sh [-cpp] OUTPUT_PATH ZIP_FILE_PATH

#OUTPUT_PATH is the folder you would like to output the submissions to.
#The script will then create a sub folder, so outputing to ~/Desktop/ is a good choice.

#ZIP_FILE_PATH is the path to the downloaded zip file from d2l brightspace. *NOTE*, do
#not change the file name of the zip, as it contains meta data required for this script_name
#to properly format the submissions. The zip will not be deleted, in case of script failure.

#If you are a cpsc1160 TA, or are marking .cpp projects in general, add the -cpp flag, which
#will provide additional C++ support including extra formatting, and auto-compiling.

#Brennan Wilkes


#Dependency check
unzip -v 2>/dev/null >/dev/null
[ $? -ne 0 ] && {
	echo "Please install dependency unzip.

	sudo apt-get install unzip
	"
	exit 2
};

#C++ mode check
[ "$1" = "-cpp" ] &&{
	shift
	cpp_mode=0
} || {
	cpp_mode=1
}

#g++ compile command
compile_cmd="g++ *.cpp -Wall -g -fsanitize=address -std=c++14 -o main"


#Usage message
script_name=$( echo -n "$0" | grep -o '[^/]*$' )
[ "$#" -lt 2 ] && {
	echo "Invalid usage format"
	echo "usage: $script_name [-cpp] OUTPUT_PATH ZIP_FILE_PATH"
	exit 1
}

#Parse lab/assignment number/name
zipfile="$2"
[ ! -f "$zipfile" ] && {
	echo "Invalid zipfile name $zipfile"
	exit 1
}

#destination output folder
destination_folder="$1"
[ ! -d "$destination_folder" ] && {
	echo "Invalid destination folder $destination_folder"
	exit 1
}


lab_number=$( echo -n "$zipfile" | grep -o '[^/]*$' | grep -o '^.*Download' | sed 's/ Download//' | sed 's/ /-/' | tr '[:upper:]' '[:lower:]')
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

#setup for percent progress indicator
num_done=0
total_to_do=$(( $( ls -l | wc -l ) - 1 ))
echo ""

#Iterate over every student folder
find . -mindepth 1 -maxdepth 1 -type d -print | while IFS= read -r  student; do

	#Debug info for slow runs when many files need to be compiled
	echo -n "\e[1A\e[0K$(( $(( $num_done * 100 )) / $(( $total_to_do )) ))% Done"
	num_done=$(( $num_done + 1 ))

	#Add newline char if not in C++ mode
	[ $cpp_mode -eq 1 ] && {
		echo ""
	}

	#Enter student folder
	cd "$student"

	#remove student directory prefix
	student=$( echo -n "$student" | sed 's/\.\///' )

	#Grab submission name and extension type
	fn=$( ls )
	extension=$( ls | grep -o '\.[^.]*$' )

	#unzip zip file submissions and remove archive
	[ "$extension" = ".zip" ] && {
		unzip -q "$fn"
		rm "$fn"
	} || {

		#Rename non-zip files to student name
		mv "$fn" "$student$extension"
	}

	#C++ specific stuff
	[ $cpp_mode -eq 0 ] && {

		#Progress debug info
		echo " - Compiling $student's project"

		#Delete leftover object and executable files
		rm *.o 2>/dev/null
		rm "main" 2>/dev/null

		#If theres a makefile, try running it
		[ -f "makefile" ] || [ -f "Makefile" ] && {
			make 2>/dev/null >&2
			rm *.o 2>/dev/null

			#makefile failed, try g++ compile command
			[ $? -ne 0 ] && {
				$compile_cmd 2>/dev/null >&2
			}
		} || {

			#no makefile, try g++ compile command
			$compile_cmd 2>/dev/null >&2
		}
	}

	#Exit to main directory
	cd ..
done


echo "\e[1A\e[0KProcessed $(( $( ls -l | wc -l ) - 1 )) students most recent submissions"
exit 0
