#downloading data
if (!file.exist('./data/')){dir.create('./data')}
fileUrl<-'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
fileName <-'./data/UCIHAR.zip'
download.file(fileUrl,destfile=fileName,method='curl')
#Load the data, appending activities, subjects and merging train and test
train <- read.table(unz(fileName, 'UCI HAR Dataset/train/X_train.txt'))
test <- read.table(unz(fileName, 'UCI HAR Dataset/test/X_test.txt'))
#Activities
trainActivities <- read.table(unz(fileName, 'UCI HAR Dataset/train/y_train.txt'))
names(trainActivities)<-'activity'
testActivities <- read.table(unz(fileName, 'UCI HAR Dataset/test/y_test.txt'))
names(testActivities)<-'activity'
train<-cbind(train,trainActivities)
test<-cbind(test,testActivities)
#Subjects
trainSubjects <- read.table(unz(fileName, 'UCI HAR Dataset/train/subject_train.txt'))
names(trainSubjects)<-'subject'
testSubjects <- read.table(unz(fileName, 'UCI HAR Dataset/test/subject_test.txt'))
names(testSubjects)<-'subject'
train<-cbind(train,trainSubjects)
test<-cbind(test,testSubjects)

alldata<-rbind(train,test)  

#label activities
getActivitiesNames<-function(x){
    if (x == 1) 'WALKING'
    else if (x == 2)  'WALKING_UPSTAIRS'
    else if (x == 3)  'WALKING_DOWNSTAIRS'
    else if (x == 4)  'SITTING'
    else if (x == 5)  'STANDING'
    else if (x == 6)  'LAYING'
}
alldata[,'activity'] <- sapply(alldata[,'activity'],getActivitiesNames)

#label features
featureNamesLines <- readLines(unz(fileName, 'UCI HAR Dataset/features.txt'))
featureNames <- c();
for (i in 1:length(featureNamesLines) ) {
  strItem <- strsplit(featureNamesLines[i], " ")[[1]]
  featureNames <- c(featureNames,strItem[2]);
}
featureNames<- c(featureNames,'activity','subject');
colnames(alldata)<-featureNames
#generating dataset with features averages grouped by subject and activity
library(plyr)
allmean<-ddply(alldata, .(subject,activity), colwise(mean))
write.csv(allmean, './data/UCI-HAR-average.csv')