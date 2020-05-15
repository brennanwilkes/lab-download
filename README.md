# lab-download
A tool to download and format lab submissions for marking by Brennan Wilkes

Run by using ./lab-download.sh [-cpp] OUTPUT_PATH ZIP_FILE_PATH

**example**
./lab-download.sh /home/Desktop/ '/home/Downloads/Lab 01 Download May 14, 2020 1129 PM.zip'

OUTPUT_PATH is the folder you would like to output the submissions to.
The script will then create a sub folder, so outputing to ~/Desktop/ is a good choice.

ZIP_FILE_PATH is the path to the downloaded zip file from d2l brightspace. *NOTE*, do
not change the file name of the zip, as it contains meta data required for this script_name
to properly format the submissions. Don't worry, the zip will not be deleted, in case of script failure.

If you are marking .cpp projects, add the -cpp flag, which
will provide additional C++ support including extra formatting, and auto-compiling.
