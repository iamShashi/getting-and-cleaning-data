library(reshape2)
library(table.data)
#using library reshape2 as in order to use the functions dcst and melt
library(lubridate)
#using lubridate just if for using date and all
fname<-"getdata_dataset.zip"
#declaring fname variable so as to check in other steps
if(!file.exists(fname)){
  fURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fURL, fname, method="curl")
}  
#checking if the file exists or not if it does not then downloaded
if (!file.exists("UCI HAR Dataset")) { 
  unzip(fname) 
}
#unzipping the down;oaded file

#reading the features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
#converting there class to character class
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
#grabbing the features only having mean and std in them
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
#replacing the faulty names by one unified name
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
#replacing the faulty names by one unified name
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)
#replacing the faulty symbols other symbols
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
#reading the dATA   into tables
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

#combining the datasets by columns
test <- cbind(testSubjects, testActivities, test)
#combining the datasets by rows
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)