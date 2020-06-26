# lab-format v1.10.3
A tool to download and format lab/assignment submissions for marking by Brennan Wilkes

*first*, download all lab/assignment submissions into a *single* zip file, and do not rename the file.

Then, run by using

                   ./lab-format.sh [ZIP_FILE_PATH] [OUTPUT_PATH] OR

                   ./lab-format.sh [ZIP_FILE_PATH] - automatic output OR

                   ./lab-format.sh - full automatic mode

**Important**
Usage has recently changed. please run ./lab-format --help for help with settings

**example**
./lab-format.sh '/home/Downloads/Lab 01 Download May 14, 2020 1129 PM.zip' /home/Desktop/

**options**

	ZIP_FILE_PATH
The path to the downloaded zip file from d2l brightspace. *NOTE*, do
not change the file name of the zip, as it contains meta data required for this script_name
to properly format the submissions. Don't worry, the zip will not be deleted, in case of script failure.

	OUTPUT_PATH
The folder you would like to output the submissions to.
The script will then create a sub folder, so outputing to ~/Desktop/ is a good choice.

**Flags/Options**

	--cpp
If you are marking C++ projects, add the --cpp flag, which
will provide additional C++ support including extra formatting, and auto-compiling.

	--help
Print usage and help messages

	--version
Print version number

**Settings**

	-s SETTING VALUE
updates a setting, 'SETTING', to value 'VALUE'

	-s NUMBER VALUE
updates a setting with id 'NUMBER' to value 'VALUE'

	-s RESET
reset to default settings

	-s VIEW
view all current settings
