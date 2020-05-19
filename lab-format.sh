#!/bin/sh

#Script for downloading and formatting lab submissions

#Run by using ./lab-format.sh [-cpp] [ZIP_FILE_PATH] [OUTPUT_PATH]

#**If you do not provide one or both of these arguments, directories from your
#  default settings folder. Your default settings folder is ~/.lab-format-settings, but
#  can be changed below**

#ZIP_FILE_PATH is the path to the downloaded zip file from d2l brightspace. *NOTE*, do
#not change the file name of the zip, as it contains meta data required for this script_name
#to properly format the submissions. The zip will not be deleted, in case of script failure.

#OUTPUT_PATH is the folder you would like to output the submissions to.
#The script will then create a sub folder, so outputing to ~/Desktop/ is a good choice.

#If you are a cpsc1160 TA, or are marking .cpp projects in general, add the -cpp flag, which
#will provide additional C++ support including extra formatting, and auto-compiling.

#Brennan Wilkes


#-----------------------------------------------SETUP-----------------------------------------------


#Path to lab settings folder. Change this if needed
LAB_FORMAT_SETTINGS_PATH="~/.lab-format-settings/"

#Usage message
script_name=$( echo -n "$0" | grep -o '[^/]*$' )

#all possible settings
settings_list="working_directory zip_search_directory compile_cmd"


#-----------------------------------------------FUNCTIONS-----------------------------------------------


#Print all current settings
print_all_settings() {
	find "${LAB_FORMAT_SETTINGS_PATH}" -type f -print | while IFS= read -r  setting; do
		echo "$( echo -n $setting | grep -o '[^/]*$' ) : $( cat $setting )"
	done
}

#Reset specific settings to default values
#This is also the master location within this script for default values.
reset_setting() {
	for setting in "$@"; do
		case "$setting" in

			"working_directory")
				echo -n "~/Desktop" > "${LAB_FORMAT_SETTINGS_PATH}working_directory"
				;;

			"zip_search_directory")
				echo -n "~/Downloads" > "${LAB_FORMAT_SETTINGS_PATH}zip_search_directory"
				;;

			"compile_cmd")
				echo -n "g++ *.cpp -Wall -g -fsanitize=address -std=c++14 -o main" > "${LAB_FORMAT_SETTINGS_PATH}compile_cmd"
				;;
		esac
	done
}

#Reset all settings to defaults
reset_all_settings() {

	#Delete all files in path folder
	[ -z "$( ls $LAB_FORMAT_SETTINGS_PATH )" ] || {
		eval rm "$LAB_FORMAT_SETTINGS_PATH*"
	}

	#Call reset on all settings
	reset_setting $settings_list
}

#-----------------------------------------------SETTINGS-----------------------------------------------


#Update formatting and export
export LAB_FORMAT_SETTINGS_PATH=$( eval echo -n "$LAB_FORMAT_SETTINGS_PATH/" | tr -s '/')

#Check for settings file
[ ! -d "$LAB_FORMAT_SETTINGS_PATH" ] && {

	#Create settings
	echo "First time run - creating settings folder at $LAB_FORMAT_SETTINGS_PATH"
	mkdir "$LAB_FORMAT_SETTINGS_PATH"
	reset_all_settings
} || {

	#Check for unset settings and set them to default
	#This verifies the integrity of the settings directory
	for setting in $settings_list; do
		[ -f "${LAB_FORMAT_SETTINGS_PATH}$setting" ] || {
			reset_setting "$setting"
		}
	done
}

#load settings
working_path=$( eval echo -n $( cat "${LAB_FORMAT_SETTINGS_PATH}working_directory" ) )
zip_search_directory=$( eval echo -n $( cat "${LAB_FORMAT_SETTINGS_PATH}zip_search_directory" ) )
compile_cmd=$( eval echo -n $( cat "${LAB_FORMAT_SETTINGS_PATH}compile_cmd" ) )


#-----------------------------------------------DEPENDENCY-----------------------------------------------


#Dependency check
unzip -v 2>/dev/null >/dev/null
[ $? -ne 0 ] && {
	echo "Please install dependency 'unzip'. (I'm working on providing gunzip and other unzip program support)

	sudo apt-get install unzip
	"
	exit 2
};


#-----------------------------------------------MODE FLAGS-----------------------------------------------


#C++ mode check
[ "$1" = "-cpp" ] &&{
	shift
	cpp_mode=0
} || {
	cpp_mode=1
}

[ "$1" = "--help" ] && {
	echo "usage: $script_name [ZIP_FILE_PATH] [OUTPUT_PATH] \n\n"
	echo "  Arguments: \n"
	echo "  [ZIP_FILE_PATH]  Path to zip file downloaded from d2l containing all student submissions \n"
	echo "  [OUTPUT_PATH]  Directory to output lab folders to. Default is ~/Desktop/ \n\n"
	echo "  Options: \n"
	echo "  -cpp  C++ Specific features. Will remove students .o and main files, and will attempt to auto-compile .cpp files \n"
	echo "  --help Display usage message. Man page coming soon (maybe?)\n"
	echo "  -s SETTING VALUE  updates a setting, 'SETTING', to value 'VALUE'"
	echo "  -s RESET  reset to default settings"
	echo "  -s VIEW  view all current settings\n"
	exit 0
}

#Settings
[ "$1" = "-s" ] && {
	shift

	#Reset
	[ "$1" = "RESET" ] && {
		reset_all_settings
		print_all_settings
		exit 0
	} || [ "$1" = "VIEW" ] && {
		#Print
		print_all_settings
		exit 0
	}

	#Check required arguments
	[ "$#" -eq 2 ] && {

		#Check valid setting key
		[ -f "${LAB_FORMAT_SETTINGS_PATH}$1" ] && {

			#update setting
			echo -n "$2" > "${LAB_FORMAT_SETTINGS_PATH}$1"
			print_all_settings

			exit 0
		} || {

			#Invalid
			echo "Invalid setting $1"
			print_all_settings

			exit 1
		}
	} || {

		#Error message
		echo "Inavlid settings key pair $1 - $2"
		echo "Usage: $script_name -s SETTING VALUE"
		echo "Usage: $script_name -s RESET"
		echo "Usage: $script_name -s VIEW"
		echo "See $script_name --help for more info"
		exit 1
	}
}


#-----------------------------------------------ARGUMENTS-----------------------------------------------


#Set explicit zipfile name
[ "$#" -ge 1 ] && {
	zipfile="$1"
	shift
} || {
	#Search zipfile directory for newest zip file

	#search for files matching ' Download [Month] [date], [year] [time] AM/PM.zip'
	#Search the zip search directory with find for files at depth level 1.
	#Print them prefixed with their creation time
	#Sort by creation time.
	#Filter by regex (see above)
	#Grab the most recent, and filter out the prefixed time
	zipfile=$( find "$zip_search_directory" -maxdepth 1 -type f -printf "%T@ %p\n" | sort -nr | grep -E ' Download \w+ [0-9][0-9]?, [0-9][0-9][0-9][0-9] [0-9][0-9]?[0-9][0-9]? [AP]M.zip$' | head -n1 | sed 's/^[0-9]*.[0-9]* //')
	[ -f "$zipfile" ] && {
		echo "Autodetected '$( echo -n "$zipfile" | grep -o '[^/]*$' )'"
		echo -n "Use? [y]/[n]: "
		read confirmation
		confirmation=$( echo -n "$confirmation" | tr "[[:upper:]]" "[[:lower:]]" )
		[ "$confirmation" = "y" ] || [ "$confirmation" = "yes" ] || {
			echo "Please explicitly state zipfile as an argument"
			echo "See $script_name --help for more info"
			exit 1
		}
	}
}



#Check for valid zipfile
[ ! -f "$zipfile" ] && {
	echo "Invalid zipfile name $zipfile"
	echo "See $script_name --help for more info"
	exit 1
}


#Set explicit working path
[ "$#" -ge 1 ] && {
	working_path="$1"
	shift
}

#check for valid working path
[ ! -d "$working_path" ] && {
	echo "Invalid destination folder $working_path"
	echo "See $script_name --help for more info"
	exit 1
}


#-----------------------------------------------MAIN-----------------------------------------------


lab_number=$( echo -n "$zipfile" | grep -o '[^/]*$' | grep -o '^.*Download' | sed 's/ Download//' | sed 's/ /-/' | tr '[:upper:]' '[:lower:]')
[ "$lab_number" = "" ] || [ "$lab_number" = " " ] && {
	echo "Invalid zip file name. Please do not rename the zip file. Leave it as downloaded from d2l brightspace"
	echo "See $script_name --help for more info"
	exit 1
}

#Generate output director
eval lab_folder=$( echo -n "$working_path/$lab_number/" | tr -s '/')

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
unzip -qo "$zipfile" -d "${lab_folder}unmarked/"

#cd to submissions folder
cd "${lab_folder}unmarked/"

#Remove manifest
rm "index.html"

#Iterate over every submission
find . -type f -print | while IFS= read -r  file; do

	#Parce student name
	name=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f2 | tr ' ' '-' )

	#Parce submission date
	date=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f3 )

	#Parce submission extension
	extension=$( echo -n "$file" | sed 's/ - /\x00/g' | cut -d '' -f4 | grep -o '\.[^.]*$')

	#Create named folder
	[ -d "$name" ] || {
		mkdir "$name" 2>/dev/null

		#Check for a duplicate submission
		[ $? -ne 0 ] && {
			echo "Please delete all existing student submission folders and rerun $script_name"
			echo "See $script_name --help for more info"
			exit 1
		}
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

#check for error in previous block
[ $? -ne 0 ] && {
	exit 1
}

#setup for percent progress indicator
num_done=0
total_to_do=$(( $( ls -l | wc -l ) - 1 ))
echo ""

extra_cd=0

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

	[ -d "$( ls )" ] && {
		cd "$( ls )"
		extra_cd=1
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
	[ "$extra_cd" -eq 1 ] && {
		extra_cd=0
		cd ..
	}
done


echo "\e[1A\e[0KProcessed $(( $( ls -l | wc -l ) - 1 )) students most recent submissions"
exit 0
