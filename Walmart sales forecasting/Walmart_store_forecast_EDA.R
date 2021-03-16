########################################################
#####
##### WALMART STORE SALES FORECASTING - EDA
#####
########################################################

require("zoo")
library(dplyr)
require(astsa)
setwd("C:/Users/Anitha Karunakaran/Documents/GSU_MSDA/Spring2 semester/Predictive Analytics/Slides/casestudy/")

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
                                                          Weekly_Temperature_allStore = sum(Temperature) )
  
#taking sum(Temperature), sum(CPI),sum(Unemployment) doesn't make sense at week level alone
#as they are related to store-week

#so instead need to pick a store in random
#lets do some EDA to select a store number

#lets plot store against Type
#plot(data$Weekly_Sales_Store, data$Type,xlab="Weekly store sales", ylab="Type")

#get count of store based on type
count.store_type = data %>% group_by(Type) %>% summarise(count_Store = n())

library(ggplot2);
ggplot(count.store_type, aes(as.factor(Type), count_Store)) +
  geom_bar(stat = "identity") + 
  labs(y = "Store count", x = "Type");

#Type A has highest store count


#lets plot store against size
#even correlation plot shows significant correlation between them
plot(data$Weekly_Sales_Store, data$Size,xlab="Weekly store sales", ylab="Size")

#lets pick one/two store per type in random from the data
#Type A: Store 20
#Type B: Store 3
#Type C: Store 30

#subset data for these store
#store 20
store_20 <- data.subset[data.subset$Store == 20,]
dim(store_20) #143   7
#write.csv(x=store_20, file="store_20.csv",row.names = FALSE)

#store 3
store_3 <- data.subset[data.subset$Store == 3,]
dim(store_3) #143   7
#write.csv(x=store_3, file="store_3.csv",row.names = FALSE)

#Store 30
store_30 <- data.subset[data.subset$Store == 30,]
dim(store_30) #143   7
#write.csv(x=store_30, file="store_30.csv",row.names = FALSE)



###########################################################################
#                                                         
################################# END #####################################
#
###########################################################################

#lets do some more EDA and plot

lapply(data, class)
#convert to numeric
data$Size <- as.numeric(data$Size)

#will only calculate correlation between two variables for those pairs where both are not-NA
CorrelationMatrix <- cor(data[,c("Store","Weekly_Sales_Store","Temperature","Fuel_Price",
        "CPI","Unemployment","Size")],use="pairwise.complete.obs")
CorrelationMatrix

#install.packages("corrplot")
library('corrplot') #package corrplot
corrplot(CorrelationMatrix, method = "circle") #plot matrix
#weekly_store_sales has slight correlation with Unemployment,CPI, Temperature

#plots
plot(data$Weekly_Sales_Store)
hist(as.numeric(data$Weekly_Sales_Store), xlab = "Weekly_Sales", main="Histogram")

plot(data$Weekly_Sales_Store, data$Store,xlab="Weekly store sales", ylab="Store")
plot(data$Weekly_Sales_Store, data$Temperature,xlab="Weekly store sales", ylab="Temp")
plot(data$Weekly_Sales_Store, data$Fuel_Price,xlab="Weekly store sales", ylab="Fuel price")
plot(data$Weekly_Sales_Store, data$CPI,xlab="Weekly store sales", ylab="CPI")
plot(data$Weekly_Sales_Store, data$Unemployment,xlab="Weekly store sales", ylab="Unemployment")
plot(data$Weekly_Sales_Store, data$Size,xlab="Weekly store sales", ylab="Size")

#check correlation between Weekly_Sales_Store and Temperature variables
ccfvalues_sales_temp = ccf(data$Weekly_Sales_Store, data$Temperature)
ccfvalues_sales_temp
# at lag -7 we see highest negative correlation 

#check correlation between Weekly_Sales_Store and CPI variables
ccf(data$Weekly_Sales_Store, data$CPI)

#check correlation between Weekly_Sales_Store and Unemployment variables
ccf(data$Weekly_Sales_Store, data$Unemployment)

#from this we can consider temprature to have significant correlation with Weekly_store_sales

plot(stats::lag(data$Weekly_Sales_Store,-7),data$Temperature)
###########################################################################
