## Install dependencies if they don't exist: plyr, dplyr
installed<-dimnames(installed.packages())[[1]] ## Contains names of all installed packages
if(!("plyr" %in% installed)){
    install.packages("plyr")
}
if(!("dplyr" %in% installed)){
    install.packages("dplyr")
}
rm("installed")

## Import used libraries
library(dplyr)

## ---------------------------------------------------------------------------------------------------

## Checks for downloaded Samsung data file with its original name, "UCI HAR Dataset" 
## If does not exist, downloads and sets the flag deleteData to TRUE. 
## This flag will be used later to delete the downloaded dataset.
deleteData <- FALSE
if(!file.exists("UCI HAR Dataset"))
{
    deleteData <- TRUE
    url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, "UCI_HAR_Dataset.zip", method="curl")
    unzip("UCI_HAR_Dataset.zip")
    unlink("UCI_HAR_Dataset.zip")
    rm(url)
}


## ---------------------------------------------------------------------------------------------------


## Loading observation (X) data to the environment.
obs_train <- read.table("UCI HAR Dataset/train/X_train.txt")
obs_test <- read.table("UCI HAR Dataset/test/X_test.txt")

## Combining observation data into the dat data frame
dat <- rbind(obs_train,obs_test)

## Removing loaded observation data, for memory purposes. 
rm(list=c("obs_train","obs_test"))


## ---------------------------------------------------------------------------------------------------


## Getting feature data and naming the observation columns in dat based on them
features<-read.table("UCI HAR Dataset/features.txt")
feat_names<-features[,2]
names(dat)<-feat_names
rm("features")


## Since we only care about mean and std data for each measurement, we can subset dat
## using a grep command over feat_names to get rid of a vast majority of the data.
## Reading through features_info, we see that each of the 33 vars have mean, std, mad, max, min, ...
## recorded. We will only get mean and std from these for each of the 33 vars.
dat<-select(dat, grep("mean[^Freq]|std",feat_names))
rm("feat_names")


## ---------------------------------------------------------------------------------------------------


## Now we can load the activity (y) data, and combine train and test data.
act_train <- read.table("UCI HAR Dataset/train/y_train.txt")
act_test <- read.table("UCI HAR Dataset/test/y_test.txt")
act <- rbind(act_train,act_test)
rm(list=c("act_train","act_test"))

## We get activity data from activity_labels.txt and join with act
activs <- read.table("UCI HAR Dataset/activity_labels.txt")
names(activs) <- c("activityId","activity")
activs <- mutate(activs, activity=tolower(activity))
names(act) <- c("activityId")
act <- plyr::join(act, activs, by="activityId")
dat <- (act %>% mutate(dat) %>% select(-1))
rm(list=c("act","activs"))


## ---------------------------------------------------------------------------------------------------


## Now, subject data will be imported, combined, and added to dat
sub_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
sub_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
sub <- rbind(sub_train,sub_test)
names(sub) <- "subject"
dat <- mutate(sub,dat)
rm(list=c("sub","sub_train","sub_test"))

## ---------------------------------------------------------------------------------------------------

## This section takes care of some column names to make them a little bit more descriptive.
## Reading the features_info.txt file, we see that the prefix t="time" and f="frequency".
## These have been incorporated. Also, words have been separated with underscores, and the 
## column names have been made lowercase.
names(dat)<-gsub("-","_",names(dat))
names(dat)<-gsub("\\(\\)","",names(dat))
names(dat)<-gsub("^t","time_domain",names(dat))
names(dat)<-gsub("^f","frequency_domain",names(dat))
names(dat)<-gsub("_([X-Z])$","\\1",names(dat))
names(dat)<-gsub("([A-Z])","_\\1",names(dat))
names(dat)<-tolower(names(dat))


## ---------------------------------------------------------------------------------------------------


## Lastly, we create our tidy dataset by grouping by subject and activity, and calculating the
## necessary averages for each variable by group
grp_dat <- group_by(dat,subject,activity)
tidy <- summarize_all(grp_dat, mean)
names(tidy)<-gsub("(^time|^frequency)","average_\\1",names(tidy))
rm("grp_dat")


## ---------------------------------------------------------------------------------------------------


## Write the summarized tidy data set (tidy) to the working directory
write.table(tidy, "UCI_HAR_tidy_data.txt", row.names = FALSE)


## ---------------------------------------------------------------------------------------------------


## Deletes downloaded data, "UCI HAR Dataset", if the script itself has downloaded it to the wd
if(deleteData){
    unlink("UCI HAR Dataset", recursive = TRUE)
}

rm(list=c("dat","tidy","deleteData"))