
import os,shutil

# storing the path
path = r"D:\Data Analyst Portfolio\_Projects\Python File Sorter"

# loop through only files in the directory
for file in os.listdir(path):
    if os.path.isfile(os.path.join(path, file)):
        # dictionary to map extensions to folder names you can add more extensions
        extensions = {
            ".csv": "Csv Folder",
            ".png": "Image Folder",
            ".jpg": "Image Folder",
            ".jpeg": "Image Folder",
            ".gif": "Image Folder",
            ".txt": "Text Folder"
        }
        
        # check if the folder exists, if not create a new folder
        for folder in extensions.values():
            if not os.path.exists(os.path.join(path, folder)):
                os.makedirs(os.path.join(path, folder))
        
        # sort the file with given extensions into the folders
        for ext, folder in extensions.items():
            if file.endswith(ext) and not os.path.exists(os.path.join(path, folder, file)):
                shutil.move(os.path.join(path, file), os.path.join(path, folder, file))
                break




