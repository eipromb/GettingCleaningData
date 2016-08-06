# set working directory -- root of data sets
#setwd("C:/ds/UCI HAR Dataset")

# load dplyr
library(dplyr)

# dataset folders
datasets    <- c("test", "train")

# init final merged dataset
final_merged <- data.frame();

# load feature names
features <- read.table('features.txt', col.names = c('feature_number', 'feature_name'))
extracted_features <- filter(features, grepl("mean\\(\\)|std\\(\\)", feature_name))

# load activity names
activities <- read.table('activity_labels.txt', col.names = c('activity_number', 'activity_name'))

for (dataset in datasets) {
  # files to read
  filename_set <- file.path(dataset, paste(c('X_', dataset, '.txt'), collapse=''))
  filename_lbl <- file.path(dataset, paste(c('Y_', dataset, '.txt'), collapse=''))
  filename_sbj <- file.path(dataset, paste(c('subject_', dataset, '.txt'), collapse=''))
  
  # read dataset, label variable names
  data_set <- read.table(filename_set, col.names=features$feature_name)
  names(data_set) <- gsub('.mean.', 'Mean', names(data_set), fixed=TRUE)
  names(data_set) <- gsub('.std.', 'StdDev', names(data_set), fixed=TRUE)
  names(data_set) <- gsub('.', '', names(data_set), fixed=TRUE)
  
  # extract data for mean and std deviation
  extracted_data <- select(data_set, extracted_features$feature_number)
  
  # read dataset labels
  data_lbl <- read.table(filename_lbl, col.names=c("activity_number"))
  data_lbl <- mutate(data_lbl, activity_name = activities$activity_name[activity_number])
  
  # read subjects 
  data_sbj <- read.table(filename_sbj, col.names=c("subject_number"))
  
  # label activities
  extracted_data <- cbind(extracted_data, activity = data_lbl$activity_name, subject = data_sbj$subject_number)
  
  # merges training and test sets
  final_merged <- rbind(final_merged, extracted_data)
}

# init final averaged dataset
data_grouped <- group_by(final_merged, activity, subject)

# get average of each variable for each activity
final_averaged <- summarise_each(data_grouped, funs(mean))

write.table(final_averaged, "step_5_data.txt", row.name=FALSE)
