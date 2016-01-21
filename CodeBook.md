Codebook
========

Variables
---------

dtTidy

Variable       | Comments
---------------|-----------
Subject        | subject identifier of volunteer (1-30)
ActivityName   | name ofactivity subject performed (LAYING,SITTING,STANDING,WALKING,WALKING_DOWNSTAIRS,WALKING_UPSTAIRS)
ftDomain       | Feature: Time or Frequency domain (Time,Freq)
ftInstrment    | Feature: Instrument measured (Accelerometer,Gyroscope)
ftAcceleration | Feature: Acceleration measured (Body,Gravity)
ftStatVariable | Feature: Stat variable (mean,std)
ftJerk         | Feature: Jerk indicator (Y)
ftMagnitude    | Feature: Magnitude indicator (Y)
ftAxis         | Feature: Axis measured (X,Y,Z)
ftAvg          | Feature: Average of measurements over subject and activity and above features (numeric)


Data
----

Number of rows in dtTidy: 11880


Transformations
---------------

1. Dataset was initially split into subject, activity, and features. Each of these were further split into test and train sets. Merging was performed to get everything in one dataset.

2. Dataset activity variable was merged with the activity lookup table to yield descriptive activity name.

3. Datset was melted with subject and activity as id variables.

4. Features were filtered to only those matching mean() or std(). Dataset was merged with derived feature code lookup table to get featureName.

5. An average was added per group of subject, activity, and feature

6. Since this is a TIDY data set, new descriptive columns were created to represent specific variables from the single feature variable (Domain,Instrument,Acceleration,StatVariable,Jerk,Magnitude and Axis) using grepl. The original feature is now redundant and removed.

7. The dataset is then written to `tidy.txt` file