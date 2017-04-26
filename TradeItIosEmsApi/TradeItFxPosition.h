//
//  TradeItFxPosition.h
//  TradeItIosEmsApi
//
//  Created by Alexander Kramer on 8/23/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol TradeItFxPosition
@end

@interface TradeItFxPosition : JSONModel<NSCopying>

// The currency pair XXX/XXX
@property (nullable, copy) NSString<Optional> *symbol;

// The type of security: FX
@property (nullable, copy) NSString<Optional> *symbolClass;

// Holding type "LONG"
@property (nullable, copy) NSString<Optional> *holdingType;

// The contract/lot size
@property (nullable, copy) NSNumber<Optional> *quantity;

// Unrealized PnL denominated in the base currency of the account
@property (nullable, copy) NSNumber<Optional> *totalUnrealizedProfitAndLossBaseCurrency;

// Total value of the position denominated in the base currency of the account
@property (nullable, copy) NSNumber<Optional> *totalValueBaseCurrency;

// Total value of the position denominated in USD
@property (nullable, copy) NSNumber<Optional> *totalValueUSD;

// Average rate of the position
@property (nullable, copy) NSNumber<Optional> *averagePrice;

// Limit price of the position
@property (nullable, copy) NSNumber<Optional> *limitPrice;

// Stop price of the position
@property (nullable, copy) NSNumber<Optional> *stopPrice;

@end
