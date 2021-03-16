########################################################
#####
##### WALMART STORE SALES FORECASTING - EDA
#####
########################################################

rm(list=ls())
graphics.off()

require("zoo")
library(dplyr)
# setwd("C:/Users/Anitha Karunakaran/Documents/GSU_MSDA/Spring2 semester/Predictive Analytics/Slides/casestudy/")

#Data extraction
#train.csv has info about store-dept-weekly sales
train = read.csv("train.csv")
str(train)
#data need to be aggregated at store date level
train.Store_Date = train %>% group_by(Store,Date) %>% summarise(Weekly_Sales_Store = sum(Weekly_Sales))
str(train.Store_Date)
head(train.Store_Date,5)
max(train.Store_Date$Date) #"2012-10-26"
min(train.Store_Date$Date) #"2010-02-05"

#features has info about store-weekly other features
features = read.csv("features.csv")
str(features)
max(features$Date) #"2013-07-26"
min(features$Date) #"2010-02-05"

#apply left join on train data with features data to get more variables
data <- merge(train.Store_Date, features, by.x = c("Store", "Date"), 
                   by.y = c("Store","Date"), all.x = TRUE, all.y = FALSE)
str(data)

#store has info about store type and size
stores = read.csv("stores.csv")
str(stores)
max(features$Date) #"2013-07-26"
min(features$Date) #"2010-02-05"

#apply left join on data with stores data to get more variables
data <- merge(data, stores, by.x = c("Store"), 
              by.y = c("Store"), all.x = TRUE, all.y = FALSE)
str(data)


#find the summary of data
summary(data)
#MarkDown(s) column has lot of NA values in it

names(data)
#lets remove these columns with lot of NA's from our dataset as they dont give much information
#and combining all store data to a week level. i.e take data at Date level
data.subset <- data[c("Store","Date","Weekly_Sales_Store","Temperature",
               "Fuel_Price","CPI","Unemployment")]

#data need to be aggregated at Date date level
data.week <- data.subset %>% group_by(Date) %>% summarise(Weekly_Sales_allStore = sum(Weekly_Sales_Store),
                                                          Weekly_Temperature_allStore = sum(Temperature),
                                                          Weekly_Temperature_allStore = )
  
#taking sum(Temperature), sum(CPI),sum(Unemployment) doesn't make sense at week level alone
#as they are related to store-week

#so instead need to pick a store in random
#lets do some EDA to select a store number

#lets plot store against Type
plot(data.subset$Weekly_Sales_Store, data.subset$Type,xlab="Weekly store sales", ylab="Type")

#get count of store based on type
count.store_type = data %>% group_by(Type) %>% summarise(count_Store = n())

library(ggplot2);
ggplot(count.store_type, aes(as.factor(Type), count_Store)) +
  geom_bar(stat = "identity") + 
  labs(y = "Store count", x = "Type");

#Type A has highest store count


#lets plot store against size
#even correlation plot shows significant correlation between them

plot(data.subset$Weekly_Sales_Store, data.subset$Size,xlab="Weekly store sales", ylab="Size")


data.subset  %>% summarize(Total_stores = n_distinct(Store))

unique(data.subset[c("Store")])
# Here we can see that there are 45 unique values for Store starting from 1 till 45

#lets pick one/two store per type in random from the data
#Type A: Store 20 and Store 41
#Type B: Store 3 and Store 45
#Type C: Store 30 and Store 44

#subset data for these store
#store 20
store_20 <- data.subset[data.subset$Store == 20,]

# Segregate the Training data and Test Data from the data file
# Out of 143 datapoints avaiable, 110 assigned to training 
# and 33 to test (80-20 Ratio)
train_store20 = store_20$Weekly_Sales_Store[1:110]
test_store20  = store_20$Weekly_Sales_Store[111:143]

# Using Library bsts to use logis and fornulaes related to Bayseian
# Statistics time series
library(bsts)


#convert to time series data
train_store20.ts = ts(train_store20,frequency = 52)

# Checking the Structure of training dataset.
str(train_store20.ts)

# Ploting the training dataset 
y = train_store20.ts
plot(y)

# To Implement BSTS, we have added Local Linear Tread and Seasonality 
# into the training dataset 
ss<-AddLocalLinearTrend(list(),y)
ss<-AddSeasonal(ss,y,nseasons = 52)

# Implementing BSTS model 
model = bsts(y, state.specification = ss,niter = 500)

# Plotting the model
plot(model)

# Checking the Components and Residuals of the model
plot(model,"components")
plot(model,"residuals")

# Calculating Burn used in predicting/ forcasting the future values
burn = SuggestBurn(0.1, model)

# Predicting the values for next one year
predict = predict(model, horizon = 52)
plot(predict, plot.original = 162 )

# Creating a Dataframe with predicted and Actual values
Ac_pr_values = data.frame(
  # fitted values and predictions
  c(as.numeric(predict$mean[1:33])),
  as.numeric((test_store20)))
names(Ac_pr_values) = c("Predicted", "Actual")

Ac_pr_values

# Calculating MSPE
MSPE <- filter(Ac_pr_values) %>% summarise(MSPE=mean((((Actual-Predicted)/Actual))^2)*100)
MSPE # 0.297

#store 3
store_3 <- data.subset[data.subset$Store == 3,]

# Segregate the Training data and Test Data from the data file
# Out of 143 datapoints avaiable, 110 assigned to training 
# and 33 to test (80-20 Ratio)
train_store3 = store_3$Weekly_Sales_Store[1:110]
test_store3  = store_3$Weekly_Sales_Store[111:143]

# Using Library bsts to use logis and fornulaes related to Bayseian
# Statistics time series
library(bsts)

#convert to time series data
train_store3.ts = ts(train_store3,frequency = 52)

# Checking the Structure of training dataset.
str(train_store3.ts)

# Ploting the training dataset 
y = train_store3.ts
plot(y)

# To Implement BSTS, we have added Local Linear Tread and Seasonality 
# into the training dataset 
ss<-AddLocalLinearTrend(list(),y)
ss<-AddSeasonal(ss,y,nseasons = 52)

# Implementing BSTS model 
model_3 = bsts(y, state.specification = ss,niter = 500)

# Plotting the model
plot(model_3)

# Checking the Components and Residuals of the model
plot(model_3,"components")
plot(model_3,"residuals")

# Calculating Burn used in predicting/ forcasting the future values
burn = SuggestBurn(0.1, model_3)

# Predicting the values for next one year
predict = predict(model_3, horizon = 52)
plot(predict, plot.original = 162 )

# Creating a Dataframe with predicted and Actual values
Ac_pr_values = data.frame(
  # fitted values and predictions
  c(as.numeric(predict$mean[1:33])),
  as.numeric((test_store3)))
names(Ac_pr_values) = c("Predicted", "Actual")

Ac_pr_values

# Calculating MSPE
MSPE <- filter(Ac_pr_values) %>% summarise(MSPE=mean((((Actual-Predicted)/Actual))^2)*100)
MSPE # 0.8948

#Store 30
store_30 <- data.subset[data.subset$Store == 30,]
# Segregate the Training data and Test Data from the data file
# Out of 143 datapoints avaiable, 110 assigned to training 
# and 33 to test (80-20 Ratio)
train_store30 = store_30$Weekly_Sales_Store[1:110]
test_store30  = store_30$Weekly_Sales_Store[111:143]

# Using Library bsts to use logis and fornulaes related to Bayseian
# Statistics time series
library(bsts)

#convert to time series data
train_store30.ts = ts(train_store30,frequency = 52)

# Checking the Structure of training dataset.
str(train_store30.ts)

# Ploting the training dataset 
y = train_store30.ts
plot(y)

# To Implement BSTS, we have added Local Linear Tread and Seasonality 
# into the training dataset 
ss<-AddLocalLinearTrend(list(),y)
ss<-AddSeasonal(ss,y,nseasons = 52)

# Implementing BSTS model 
model_30 = bsts(y, state.specification = ss,niter = 500)

# Plotting the model
plot(model_30)

# Checking the Components and Residuals of the model
plot(model_30,"components")
plot(model_30,"residuals")

# Calculating Burn used in predicting/ forcasting the future values
burn = SuggestBurn(0.1, model_30)

# Predicting the values for next one year
predict = predict(model_30, horizon = 52)
plot(predict, plot.original = 162 )

# Creating a Dataframe with predicted and Actual values
Ac_pr_values = data.frame(
  # fitted values and predictions
  c(as.numeric(predict$mean[1:33])),
  as.numeric((test_store30)))
names(Ac_pr_values) = c("Predicted", "Actual")

Ac_pr_values

# Calculating MSPE
MSPE <- filter(Ac_pr_values) %>% summarise(MSPE=mean((((Actual-Predicted)/Actual))^2)*100)
MSPE # 0.06392789

