# Getting and Cleaning UCI HAR Data

This project involves downloading, loading, and cleaning UCI HAR data from http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones. The final output of the data is a tidy data set as per the conditions given in the project guidelines.

The script works through the following steps:
1. Checks if required libraries (plyr and dplyr) are present. If not, the library is downloaded.
2. Checks if required directory "UCI HAR Dataset" is present. If not, downloads the dataset as a zip and unzips the contents. The zip is deleted after extraction. A flag records if the script downloaded the dataset (and needs to be deleted later) or if the dataset was already present in the working directory.
3. Loads the observation (X) data and combines training and test data. Adds descriptive column names from the given features.txt file.
4. Observation data columns are selected by column names to only retain mean and std data for each of the variables.
5. Loads the activity (y) data, and finds the name of each activity from activity_labels.txt. These tables are joined, and then the activity name is appended to each row of the observation data frame.
6. Loads the subject data, which are appended to each row of the observation data frame (called dat).
7. Some text cleaning is performed on the column names of dat to make them more descriptive and clear, as well as to make them all lowercase for ease of use.
8. The data frame is grouped by subject and activity, and a tidy summary data frame is made (called tidy) by calculating the average of each measurement in dat by subject and activity.
9. The tidy data frame is written into a text file called UCI_HAR_tidy_data.txt.
