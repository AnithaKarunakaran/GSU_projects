library(astsa)

#importing data
store_3=read.csv("store_3.csv")
store_20=read.csv("store_20.csv")
store_30=read.csv("store_30.csv")

#handling date column
store_3$Date <- as.Date(store_3$Date , format = "%Y-%m-%d")
store_20$Date <- as.Date(store_20$Date , format = "%Y-%m-%d")
store_30$Date <- as.Date(store_30$Date , format = "%Y-%m-%d")

#Split test train
#store3
train_store3 = store_3[1:110, ]
test_store3  = store_3[111:143, ]
#store20
train_store20 = store_20[1:110, ]
test_store20  = store_20[111:143, ]
#store30
train_store30 = store_30[1:110, ]
test_store30  = store_30[111:143, ]


############################################
################ store 3 ##################

#fitting LR model
fit_3 <- lm(Weekly_Sales_Store ~ Date + Temperature + Fuel_Price + CPI + Unemployment, data=train_store3)
summary(fit_3) 
#Findings: We found that only 'Temperature' attribute is significant for making predictions.

#understanding ACF_PACF of residual
acf2(fit_3$residuals)

#diagnosis
sarima(train_store3$Weekly_Sales_Store,5,0,5,0,0,0,S=7,xreg=cbind(train_store3$Temperature))

#predictions
result_3=sarima.for(train_store3$Weekly_Sales_Store, n.ahead = 33,5,0,5,0,0,0,S=7,
                    newxreg=cbind(train_store3$Temperature))

#mspe
mspe=100*mean(((test_store3$Weekly_Sales_Store - result_3$pred)/test_store3$Weekly_Sales_Store)^2)
print(paste('MSPE value for the sales of store 3 is:', round(mspe,3)))




############################################
################ store 20 ##################

#fitting LR model
fit_20 <- lm(Weekly_Sales_Store ~ Date + Temperature + Fuel_Price + CPI + Unemployment, 
             data=train_store20)
summary(fit_20)
#Findings: We found that only 'Temperature' attribute is significant for making predictions.

#understanding ACF_PACF of residual
acf2(fit_20$residuals)

#diagnosis
sarima(train_store20$Weekly_Sales_Store,5,0,5,0,0,0,S=7,xreg=cbind(train_store20$Temperature))

#predictions
result_20=sarima.for(train_store20$Weekly_Sales_Store, n.ahead = 33,5,0,5,0,0,0,S=7,
                     newxreg=cbind(train_store20$Temperature))

#mspe
mspe=100*mean(((test_store20$Weekly_Sales_Store - result_20$pred)/test_store20$Weekly_Sales_Store)^2)
print(paste('MSPE value for the sales of store 3 is:', round(mspe,3),'%'))







############################################
################ store 30 ##################

#fitting LR model
fit_30 <- lm(Weekly_Sales_Store ~ Date + Temperature + Fuel_Price + CPI + Unemployment, 
             data=train_store30)
summary(fit_30)

#understanding ACF_PACF of residual
acf2(fit_30$residuals)

#diagnosis
sarima(train_store30$Weekly_Sales_Store,7,0,7,0,0,0,S=7,
       xreg=cbind(train_store30$Temperature, train_store30$Date, train_store30$Unemployment))

#predictions
result_30=sarima.for(train_store30$Weekly_Sales_Store, n.ahead = 33,5,0,5,0,0,0,S=7,
    newxreg=cbind(train_store30$Temperature, train_store30$Date, train_store30$Unemployment))

#mspe
mspe=100* mean(((test_store30$Weekly_Sales_Store - result_30$pred)/test_store30$Weekly_Sales_Store)^2)
print(paste('MSPE value for the sales of store 3 is:', round(mspe,3),'%'))


