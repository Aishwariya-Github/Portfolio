import os, shutil
path = r"D:/DATA TRANSFER/Documents/Data_Analyst/Alex The Analyst (PYTHON)/Automated File Sorter/"
file_names = os.listdir(path) # show what files are in the path

folder_names = ["apk files", "image files", "excel files"]
for loop in range(len(folder_names)): # make folders if not already exists
    if not os.path.exists(path + folder_names[loop]):
        os.makedirs(path + folder_names[loop])
    
for file in file_names: # move the files into their right folders
    if ".apk" in file and not os.path.exists(path + "apk files/" + file):
        shutil.move(path + file, path + "apk files/" + file)
    elif ".png" in file and not os.path.exists(path + "image files/" + file):
        shutil.move(path + file, path + "image files/" + file)
    elif ".xlsx" in file and not os.path.exists(path + "excel files/" + file):
        shutil.move(path + file, path + "excel files/" + file)
    
