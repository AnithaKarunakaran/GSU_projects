########################################################
#####
##### WALMART STORE SALES FORECASTING - SARIMA without additional variables
#####
########################################################

setwd("C:/Users/Anitha Karunakaran/Documents/GSU_MSDA/Spring2 semester/Predictive Analytics/Slides/casestudy/")
require(astsa)
require(dplyr)

#read data of stores
store_20 = read.csv("store_20.csv")
dim(store_20)

store_3 = read.csv("store_3.csv")
dim(store_3)

store_30 = read.csv("store_30.csv")
dim(store_30)

#####################################################################
## STORE 20
#####################################################################
# split data to train and test
# check acf and pacf for the store data and find right models
# Taking only Weekly_Sales_store column for this analysis
train_store20 = store_20$Weekly_Sales_Store[1:110]
test_store20  = store_20$Weekly_Sales_Store[111:143]

#convert to time series data
train_store20.ts = ts(train_store20,frequency = 52)
plot(train_store20.ts)

#lets take look at various components of timeseries
plot(decompose(train_store20.ts))
# we observe some seasonality and increasing trend

acf2(train_store20.ts, max.lag = 100)

#lets try to remove trend in timeseries
train_store20.ts.transformed = diff(log(train_store20.ts))
plot(train_store20.ts.transformed)
plot(decompose(train_store20.ts.transformed))

acf2(train_store20.ts.transformed, max.lag = 100)


#the data looks better, lets try to remove seasonality
train_store20.ts.decompose = decompose(train_store20.ts)
train_store20.ts.noSeasonal = train_store20.ts - train_store20.ts.decompose$seasonal
plot(train_store20.ts.noSeasonal)
plot(decompose(train_store20.ts.noSeasonal))
#data looks more random now

acf2(train_store20.ts.noSeasonal, max.lag = 100)
#though the data looks more random now, acf and pacf graph gives no clue of what model I should use

#lets use original data to find appropriate model
acf2(train_store20.ts, max.lag = 100)
#no seasonal part (s=0), 
#pacf cut of at lag 1, regular ar(1)
#for regular ARMA see within 1st 52 lag
#acf higher value till lag 1 ma(1), pacf cut off at lag 1, ar(1)
#we can also try arma(1,2)

#Model diagnostic
#regular ar(1)
#arma(1,0)*(0,0)
sarima(train_store20.ts,1,0,0,0,0,0,0)
#most of the pvalue are below or on the blue line, so its not good model

#regular ma(1)
#arma(0,1)*(0,0)
sarima(train_store20.ts,0,0,1,0,0,0,0)
#most of the pvalue are below or on the blue line, so its not good model

#arma(1,1) no seasonal
#arma(1,1)*(0,0)
sarima(train_store20.ts,1,0,1,0,0,0,0)
#p value in Ljung box improved, so far this is the better model we got

library(forecast)
auto.arima(train_store20.ts, trace=TRUE)

#lets also try a model with only seasonal diff component
#and lets take diff of seasonal component
#arma(0,0,0)*(0,1,0)
sarima(train_store20.ts,0,0,0,0,1,0,0)
#pvalues are above blue line, so no correlation between residuals
#but QQ plot shows huge deviation

#Model fitting
#lets fit the data on #arma(1,1)*(0,0) - better model
fit <- Arima(train_store20.ts,c(1,0,1),seasonal=list(order=c(0,0,0),period=52))

#PREDICTION
fit2 <- Arima(test_store20,c(1,0,1),seasonal=list(order=c(0,0,0),period=52),model=fit)
onestep <- fitted(fit2)
plot(onestep)
print(paste("error of prediction",mean(test_store20-as.vector(onestep)^2)))

#lets use arima function to predict
#PREDICTION
predict = predict(arima(test_store20, order = c(1,0,1)), n.ahead = 33)
error1 = test_store20 - predict$pred
error1

#MAPE
mape1 = mean((abs(error1)/test_store20))
print(paste("MAPE",mape1))

#MSPE
mspe1 = mean(((error1)^2/test_store20))
print(paste("MSPE",mspe1))

print(paste("MSPE",100*mean(((test_store20 - predict$pred)/test_store20)^2)))

#####################################################################
## STORE 3
#####################################################################
# split data to train and test
# check acf and pacf for the store data and find right models
train_store3 = store_3$Weekly_Sales_Store[1:110]
test_store3  = store_3$Weekly_Sales_Store[111:143]

#convert to time series data
train_store3.ts = ts(train_store3,frequency = 52)
plot(train_store3.ts)

#lets take look at various components of timeseries
plot(decompose(train_store3.ts))
# we observe some seasonality and increasing trend

acf2(train_store3.ts, max.lag = 100)

#lets try to remove trend in timeseries
train_store3.ts.transformed = diff(log(train_store3.ts))
plot(train_store3.ts.transformed)
plot(decompose(train_store3.ts.transformed))

acf2(train_store3.ts.transformed, max.lag = 100)

#the data looks better, lets try to remove seasonality
train_store3.ts.decompose = decompose(train_store3.ts)
train_store3.ts.noSeasonal = train_store3.ts - train_store3.ts.decompose$seasonal
plot(train_store3.ts.noSeasonal)
plot(decompose(train_store3.ts.noSeasonal))
#data looks more random now

acf2(train_store3.ts.noSeasonal, max.lag = 100)
#though the data looks more random now, acf and pacf graph gives no clue of what model I should use

#lets use original data to find appropriate model
acf2(train_store3.ts, max.lag = 100)
#no seasonal part (s=0), 
#pacf cut of at lag 1, regular ar(1)
#for regular ARMA see within 1st 52 lag
#acf higher value till lag 4 ma(4), pacf cut off at lag 1, ar(1)
#we can also try arma(1,4)

#Model diagnostic
#regular ar(1)
#arma(1,0)*(0,0)
sarima(train_store3.ts,1,0,0,0,0,0,0)
#most of the pvalue are below or on the blue line, so its not good model

#regular ma(4)
#arma(0,4)*(0,0)
sarima(train_store3.ts,0,0,4,0,0,0,0)
#most of the pvalue are above the blue line, so its good model

#arma(1,4) no seasonal
#arma(1,4)*(0,0)
sarima(train_store3.ts,1,0,4,0,0,0,0)
#p value in Ljung box improved, this is a good model
#but we want to use only the simple model so lets use ma(4) to predict values

library(forecast)
auto.arima(train_store3.ts, trace=TRUE)

#lets also try a model with only seasonal diff component
#and lets take diff of seasonal component along with ar(1)
#arma(1,0,4)*(0,1,0)
sarima(train_store3.ts,1,0,4,0,1,0,0)
#pvalues are above blue line, so no correlation between residuals
#but QQ plot shows huge deviation

#Model fitting
#lets fit the data on #arma(0,4)*(0,0) - better model
fit <- Arima(train_store3.ts,c(0,0,4),seasonal=list(order=c(0,0,0),period=52))

#PREDICTION
fit2 <- Arima(test_store3,c(0,0,4),seasonal=list(order=c(0,0,0),period=52),model=fit)
onestep <- fitted(fit2)
plot(onestep)
print(paste("error of prediction",mean(test_store3-as.vector(onestep)^2)))

#lets use arima function to predict
#PREDICTION
predict = predict(arima(test_store3, order = c(0,0,4)), n.ahead = 33)
error1 = test_store3 - predict$pred
error1

#MAPE
mape1 = mean((abs(error1)/test_store3))
print(paste("MAPE",mape1))

#MSPE
mspe1 = mean(((error1)^2/test_store3))
print(paste("MSPE",mspe1))

print(paste("MSPE",100*mean(((test_store3 - predict$pred)/test_store3)^2)))

#####################################################################
## STORE 30
#####################################################################
# split data to train and test
# check acf and pacf for the store data and find right models
train_store30 = store_30$Weekly_Sales_Store[1:110]
test_store30  = store_30$Weekly_Sales_Store[111:143]

#convert to time series data
train_store30.ts = ts(train_store30,frequency = 52)
plot(train_store30.ts)

#lets take look at various components of timeseries
plot(decompose(train_store30.ts))
# we observe some seasonality and decreasing trend

acf2(train_store30.ts, max.lag = 100)

#lets try to remove trend in timeseries
train_store30.ts.transformed = diff(log(train_store30.ts))
plot(train_store30.ts.transformed)
plot(decompose(train_store30.ts.transformed))

acf2(train_store30.ts.transformed, max.lag = 100)

#the data looks better, lets try to remove seasonality
train_store30.ts.decompose = decompose(train_store30.ts)
train_store30.ts.noSeasonal = train_store30.ts - train_store30.ts.decompose$seasonal
plot(train_store30.ts.noSeasonal)
plot(decompose(train_store3.ts.noSeasonal))
#data looks more random now

acf2(train_store30.ts.noSeasonal, max.lag = 100)
#though the data looks more random now, acf and pacf graph gives no clue of what model I should use

#lets use transformed data to find appropriate model
acf2(train_store30.ts.transformed, max.lag = 100)
#no seasonal part (s=0), 
#pacf cut of at lag 3, regular ar(3)
#for regular ARMA see within 1st 52 lag
#acf higher value at lag 1 ma(1), pacf cut off at lag 3, ar(3)
#we can also try arma(3,1)

#Model diagnostic
#regular ar(3)
#arma(3,0)*(0,0)
sarima(train_store30.ts,3,0,0,0,0,0,0)
#most of the pvalue are below or on the blue line, so its not good model

#regular ma(1)
#arma(0,1)*(0,0)
sarima(train_store30.ts,0,0,1,0,0,0,0)
#most of the pvalue are below or on the blue line, so its not good model

#arma(3,1) no seasonal
#arma(3,1)*(0,0)
sarima(train_store3.ts,3,0,1,0,0,0,0)
#p value in Ljung box improved, this is a good model

library(forecast)
auto.arima(train_store30.ts, trace=TRUE)

#lets also try a model with only seasonal diff component
#and lets take diff of seasonal component along with arma(3,1)
#arma(3,0,1)*(0,1,0)
sarima(train_store30.ts,3,0,1,0,1,0,0)
#pvalues are above blue line, so no correlation between residuals
#but QQ plot shows huge deviation

#Model fitting
#lets fit the data on #arma(3,0,1)*(0,0,0) - better model
fit <- Arima(train_store30.ts,c(3,0,1),seasonal=list(order=c(0,0,0),period=52))

#PREDICTION
fit2 <- Arima(test_store30,c(3,0,1),seasonal=list(order=c(0,0,0),period=52),model=fit)
onestep <- fitted(fit2)
plot(onestep)
print(paste("error of prediction",mean(test_store30-as.vector(onestep)^2)))

#lets use arima function to predict
#PREDICTION
predict = predict(arima(test_store30, order = c(3,0,1)), n.ahead = 33)
error1 = test_store30 - predict$pred
error1

#MAPE
mape1 = mean((abs(error1)/test_store30))
print(paste("MAPE",mape1))

#MSPE
mspe1 = mean(((error1)^2/test_store30))
print(paste("MSPE",mspe1))

print(paste("MSPE",100*mean(((test_store30 - predict$pred)/test_store30)^2)))
