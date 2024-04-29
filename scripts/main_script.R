####  Use your Key ####

# First check your working directory

getwd()

# 1. Create there a File (in Windows with the Windows-Editor)

# 2. Write on the first line without any space Key=Your_Key 
  # Note: Your_Key is the Key you got from the Guardians-API

# Important: Call the file .Renviron it is already in the gitignore-file
# Note: When you save the file check that you change the Data-Type

# 3. Restart your R-Session (Session/Restart R)

# 4. Use this Code to read in your Key - It should appear in the Global Environment

api_key <- Sys.getenv(x= "Key")

#### Create a Corpus ####