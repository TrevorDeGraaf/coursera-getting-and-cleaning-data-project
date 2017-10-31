## Getting and Cleaning data Course Project
## TREVOR DE GRAAF

## project Goals
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## getting data and unzipping it
## checked if file was there if not created new file.
if (!file.exists("./projectdata")){
  dir.create("./projectdata")
} 

## download data from url
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./projectdata/Dataset.zip")

## unzip the file if it hasn't been done yet
if(!file.exists("UCI HAR Dataset")){
  unzip("./projectdata/Dataset.zip", exdir = "./projectdata")
}


## 1. Merges the training and the test sets to create one data set.

## getting list of files names from zip file including all that are in additional folders used to get file names
list_files <- list.files("./UCI HAR Dataset", recursive = TRUE)

## setting path to the unzipped for for ease of use
setwd("./projectdata/UCI HAR Dataset")


## read data from file general 
features <- read.table("./features.txt", header = FALSE)
activities <- read.table("./activity_labels.txt", header = FALSE)

## train files
trainsubject <- read.table("./train/subject_train.txt", header = FALSE)
xtrain <- read.table("./train/X_train.txt", header = FALSE)
ytrain <- read.table("./train/y_train.txt", header = FALSE)

## test files
testsubject <- read.table("./test/subject_test.txt", header = FALSE)
xtest <- read.table("./test/X_test.txt", header = FALSE)
ytest <- read.table("./test/y_test.txt", header = FALSE)


## assigning names to columns to data. 
colnames(activities) <- c("activityId", "activityType")
colnames(trainsubject) <- "subjectId"
colnames(xtrain) <- features[,2]
colnames(ytrain) <- "activityId"
colnames(testsubject) <- "subjectId"
colnames(xtest) <- features[,2]
colnames(ytest) <- "activityId"

## combining data within for both train and test

subject <- rbind(trainsubject,testsubject)
activity <- rbind(ytrain,ytest)
feats <- rbind(xtrain,xtest)

names(subject) <- "subject"
names(activity) <- "activity"
featurenames <- read.table("./features.txt", header = FALSE)
names(feats) <- featurenames$V2

DC <- cbind(subject, activity)
Data <- cbind(feats, DC)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.


## using grep to find mean and std in data names then subsetining into data.

subfeats <- featurenames$V2[grep("mean\\(\\)|std\\(\\)",featurenames$V2)]
sNames <- c(as.character(subfeats), "subject", "activity")
Data<-subset(Data, select = sNames)


## 3. Uses descriptive activity names to name the activities in the data set

## subbing the activityID number for actual activity note loop wasn't working so did the long way
Data$activity <- gsub("1", "walking", Data$activity)
Data$activity <- gsub("2", "walking upstairs", Data$activity)
Data$activity <- gsub("3", "walking downstairs", Data$activity)
Data$activity <- gsub("4", "sitting", Data$activity)
Data$activity <- gsub("5", "standing", Data$activity)
Data$activity <- gsub("6", "laying", Data$activity)

##  4. Appropriately labels the data set with descriptive variable names.

## subbing short hand for actual word. 
names(Data)<- gsub("^f", "Freq", names(Data))
names(Data)<- gsub("^t", "Time", names(Data))
names(Data)<- gsub("Acc", "Accelermeter", names(Data))
names(Data)<- gsub("Gyro", "Gyro", names(Data))
names(Data)<- gsub("Mag", "Magnitude", names(Data))
names(Data)<- gsub("BodyBody", "Body", names(Data))



## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# averages all data and sort by subject and activity.
TidyData<- ddply(Data, .(subject, activity), function(x) colMeans(x[,1:66])) 



## submision tidydata export
write.table(TidyData, "Tidy_Data.txt", row.names = FALSE)


