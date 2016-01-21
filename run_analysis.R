library(data.table)
library(reshape2)

path <- getwd()

url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
f <- 'Dataset.zip'
if(!file.exists(f)) {
  download.file(url,f)
}
d <- 'UCI HAR Dataset'
if(!file.exists(d)) {
  unzip(f)
}

#read subjects
dtSubjTrain <- data.table(read.table(file.path(path, d, 'train', 'subject_train.txt')))
dtSubjTest <- data.table(read.table(file.path(path, d, 'test', 'subject_test.txt')))
dtSubj <- rbind(dtSubjTrain, dtSubjTest)
names(dtSubj) <- c('Subject')
remove(dtSubjTrain,dtSubjTest)

#read activities
dtActTrain <- data.table(read.table(file.path(path, d, 'train','Y_train.txt')))
dtActTest <- data.table(read.table(file.path(path,d,'test','Y_test.txt')))
dtAct <- rbind(dtActTrain,dtActTest)
names(dtAct) <- c('Activity')
remove(dtActTrain,dtActTest)

#combine subject and activity
dtSubj <- cbind(dtSubj,dtAct)
remove(dtAct)

#read feature data
dtTrain <- data.table(read.table(file.path(path,d,'train','X_train.txt')))
dtTest <- data.table(read.table(file.path(path,d,'test','X_test.txt')))
dt <- rbind(dtTrain,dtTest)
remove(dtTrain,dtTest)

#merge into one table subject/activity/feature
dt <- cbind(dtSubj,dt)
#set key to subject/activity
setkey(dt,Subject,Activity)
remove(dtSubj)

#read feature names, get only std and mean features
dtFeats <- data.table(read.table(file.path(path,d,'features.txt'))) 
names(dtFeats) <- c('ftNum','ftName')
dtFeats <- dtFeats[grepl("mean\\(\\)|std\\(\\)",ftName)]
dtFeats$ftCode <- paste('V', dtFeats$ftNum, sep = "")

#select only the filtered features (with=FALSE to dynamically pick cols)
dt <- dt[,c(key(dt), dtFeats$ftCode),with=F]

#read activity names
dtActNames <- data.table(read.table(file.path(path, d, 'activity_labels.txt')))
names(dtActNames) <- c('Activity','ActivityName')
dt <- merge(dt,dtActNames,by='Activity')
remove(dtActNames)
#add activityname as a key
setkey(dt,Subject,Activity,ActivityName)

#reshape data
dt <- melt(dt, key(dt), variable.name='ftCode',value.name='ftValue')
dt$Activity <- NULL

#merge in ftName
dt <- merge(dt,dtFeats,by='ftCode')
setkey(dt,Subject,ActivityName,ftName)

dtTidy <- dt[,.(ftAvg=mean(ftValue)),by=key(dt)]

#start seperating out featName column to seperate columns
#ftDomain: TIME FREQ
dtTidy$ftDomain[grepl('^t',dtTidy$ftName)] <- 'Time'
dtTidy$ftDomain[grepl('^f',dtTidy$ftName)] <- 'Freq'
#ftInstrment:  Accelerometer Gyroscope
dtTidy$ftInstrment[grepl('Acc',dtTidy$ftName)] <- 'Accelerometer'
dtTidy$ftInstrment[grepl('Gyro',dtTidy$ftName)] <- 'Gyroscope'
#ftAcceleration:  Body Gravity
dtTidy$ftAcceleration[grepl('BodyAcc',dtTidy$ftName)] <- 'Body'
dtTidy$ftAcceleration[grepl('GravityAcc',dtTidy$ftName)] <- 'Gravity'
#ftStatVariable:  mean std
dtTidy$ftStatVariable[grepl('mean()',dtTidy$ftName)] <- 'mean'
dtTidy$ftStatVariable[grepl('std()',dtTidy$ftName)] <- 'std'
#ftJerk: Y
dtTidy$ftJerk[grepl('Jerk', dtTidy$ftName)] <- 'Y'
#ftMagnitude: Y
dtTidy$ftMagnitude[grepl('Mag', dtTidy$ftName)] <- 'Y'
#ftAxis:  X Y Z
dtTidy$ftAxis[grepl('-X', dtTidy$ftName)] <- 'X'
dtTidy$ftAxis[grepl('-Y', dtTidy$ftName)] <- 'Y'
dtTidy$ftAxis[grepl('-Z', dtTidy$ftName)] <- 'Z'

dtTidy$ftName <- NULL

write.table(dtTidy, file.path(path, 'tidy.txt'))