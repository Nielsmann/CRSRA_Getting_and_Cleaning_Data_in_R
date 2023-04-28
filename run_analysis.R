##### Load relevant R package
library(tidyverse)


##### Create temporary store file and download zip-file from URL 
##### and store it in the temporary file
temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)


##### List the different data files and their paths contained in the ZIP archive
unzip(temp, list = TRUE)


##### Read test data and training data files from ZIP archive
TrainDat <- read_table(unzip(temp,files = "UCI HAR Dataset/train/X_train.txt"), col_names = FALSE)
TestDat <- read_table(unzip(temp,files = "UCI HAR Dataset/test/X_test.txt"), col_names = FALSE)


##### Read the features file with the column names from ZIP archive and
##### 'pull' the column "X2" as a vector
Header <- read_table(unzip(temp,files = "UCI HAR Dataset/features.txt"), col_names = FALSE)
Header <- Header %>% pull(X2)


##### Assign the new column names from the vector "Header" to the TrainDat 
##### and the TestDat data set
names(TrainDat) <- c(Header)
names(TestDat) <- c(Header)


##### Read activity label codes for test data and training data files from ZIP archive
TrainDatLabelCodes <- read_table(unzip(temp,files = "UCI HAR Dataset/train/y_train.txt"), col_names = FALSE)
TestDatLabelCodes <- read_table(unzip(temp,files = "UCI HAR Dataset/test/y_test.txt"), col_names = FALSE)


#### Add column with TrainingDat-LabelCodes to TrainDat
TrainDat <- cbind(TrainDatLabelCodes, TrainDat)


#### Add column with TestDat-LabelCodes to TestDat
TestDat <- cbind(TestDatLabelCodes, TestDat)


##### Read activity labels with descriptive activity names => create Lookup-Table
ActivityLabels <- read_table(unzip(temp,files = "UCI HAR Dataset/activity_labels.txt"), col_names = FALSE)


##### Merge Training and Test data sets vertically
AllData <- rbind(TrainDat, TestDat)
AllData <- AllData %>% select(contains(c("X1","mean()","std()")))


##### Crate a look-up column with descriptive activity labels taken from 
##### ActivityLabels + relocate new column towards beginning of data set
AllData <- left_join(AllData, ActivityLabels, by = "X1")
AllData <-  AllData %>% relocate(X2, .after = X1) %>% 
  rename("ActivityLabel" = "X2")

##### Remove column named "X1" containing the activity code number, no longer relevant
AllData <- select(AllData, -c(X1))


##### Crate a new and tidy dataframe with mean values of all variables grouped
##### by activity
TidyDataSet <- AllData %>% group_by(ActivityLabel) %>% summarise(across(everything(), list(mean)))

write.table(TidyDataSet,file = "TidyDataSet.txt", row.name=FALSE)

##### Remove unnecessary objects
rm(TestDatLabelCodes, TrainDatLabelCodes, ActivityLabels, Header, temp, TestDat, TrainDat)


##### Release some RAM memory
gc() 
