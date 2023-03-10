# Python File Sorter

This Python script sorts files in a directory into different folders based on their file extensions. The script can be customized to sort files with specific extensions into user-defined folders.

## How to Use

1. Update the 'path' variable in the Python script to the directory containing the files you want to sort.

2. Customize the 'extensions' dictionary in the Python script to define the file extensions and corresponding folder names. The current code sorts '.csv', '.png', '.jpg', '.jpeg', '.gif', and '.txt' files into 'Csv Folder', 'Image Folder', and 'Text Folder'.

3. Run the Python script.

4. The script will create folders for each unique folder name defined in the 'extensions' dictionary. Files with matching extensions will be moved to their corresponding folders.

## Example

Suppose you have a directory containing the following files:

file1.csv
file2.txt
file3.png
file4.doc

After running the Python script, the directory will contain the following files and folders:
Csv Folder/file1.csv
Text Folder/file2.txt
Image Folder/file3.png
file4.doc

The 'file4.doc' file is not sorted because its file extension is not defined in the 'extensions' dictionary.
