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

script_name=$( echo -n "$0" | grep -o '[^/]*$' )

[ "$#" -lt 1 ] && {
	echo "usage: $script_name ZIP_FILE_PATH"
	exit 1
}

zipfile=$1
