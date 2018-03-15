//
//  TradeItPosition.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/3/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol TradeItPosition
@end

@interface TradeItPosition : JSONModel<NSCopying>

// The exchange symbol, or cusip for bonds
@property (nullable, copy) NSString<Optional> *symbol;

// The type of security: OPTION, EQUITY_OR_ETF, BUY_WRITES, SPREADS, COMBO, MULTILEG, MUTUAL_FUNDS, FIXED_INCOME, CASH, UNKNOWN, FX, FUTURE
@property (nullable, copy) NSString<Optional> *symbolClass;

// "LONG" or "SHORT"
@property (nullable, copy) NSString<Optional> *holdingType;

// The total base cost of the security
@property (nullable, copy) NSNumber<Optional> *costbasis;

// The last traded price of the security
@property (nullable, copy) NSNumber<Optional> *lastPrice;

// The total quantity held. It's a double to support cash and Mutual Funds
@property (nullable, copy) NSNumber<Optional> *quantity;

// The total gain/loss in dollars for the day for the position
@property (nullable, copy) NSNumber<Optional> *todayGainLossDollar DEPRECATED_MSG_ATTRIBUTE("Use todayGainLossAbsolute instead.");

// The total gain/loss in currency for the day for the position
@property (nullable, copy) NSNumber<Optional> *todayGainLossAbsolute;

// The percentage gain/loss for the day for the position
@property (nullable, copy) NSNumber<Optional> *todayGainLossPercentage;

// The total gain/loss in dollars for the position
@property (nullable, copy) NSNumber<Optional> *totalGainLossDollar DEPRECATED_MSG_ATTRIBUTE("Use totalGainLossAbsolute instead.");

// The total gain/loss in currency specified for the position
@property (nullable, copy) NSNumber<Optional> *totalGainLossAbsolute;

// The total percentage of gain/loss for the position
@property (nullable, copy) NSNumber<Optional> *totalGainLossPercentage;

@property (nullable, copy) NSString<Optional> *exchange;

@property (nullable, copy) NSString<Optional> *currencyCode;

@property (nullable, copy) NSString<Optional>  *positionDescription;

@end
