require("data.table")
require("reshape2")

if (!file.exists("./getdata-projectfiles-UCI HAR Dataset.zip")) {
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "getdata-projectfiles-UCI HAR Dataset.zip", method="curl")
}
dir.create("./UCI HAR Dataset")
unzip("./getdata-projectfiles-UCI HAR Dataset.zip")

# Load Activity Labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load Features that contains data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_measurements <- grepl("mean|std", features)

##
## Load test data
##
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names=features)
# Extract only the measurements on the mean and standard deviation for each measurement.
X_test <- X_test[,extract_measurements]

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names="subject")

y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
# Add activity label
y_test[,2] <- activity_labels[y_test[,1]]
names(y_test) <- c("Activity_ID", "Activity_Label")

##
## Load train data
##
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names=features)
# Extract only the measurements on the mean and standard deviation for each measurement.
X_train <- X_train[,extract_measurements]

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names="subject")

y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
# Add activity label
y_train[,2] <- activity_labels[y_train[,1]]
names(y_train) <- c("Activity_ID", "Activity_Label")

##
## Bind data
##
test  <- cbind( as.data.table(subject_test),  y_test,  X_test  )
train <- cbind( as.data.table(subject_train), y_train, X_train )
data  <- rbind(test, train)

##
## Export tidy data
##
labels      <- c("subject", "Activity_ID", "Activity_Label")
data_labels <- setdiff(colnames(data), labels)
melt_data   <- melt(data, id = labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt", row.names=FALSE)