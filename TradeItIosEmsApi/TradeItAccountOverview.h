//
//  TradeItAccountOverview.h
//  TradeItIosEmsApi
//
//  Created by Guillaume Debavelaere on 8/25/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface TradeItAccountOverview : JSONModel

// The total account value
@property (nullable, copy) NSNumber<Optional> *totalValue;

// Cash available to withdraw
@property (nullable, copy) NSNumber<Optional> *availableCash;

// The buying power of the account
@property (nullable, copy) NSNumber<Optional> *buyingPower;

// The daily return of the account
@property (nullable, copy) NSNumber<Optional> *dayAbsoluteReturn;

// The daily return percentage
@property (nullable, copy) NSNumber<Optional> *dayPercentReturn;

// The total absolute return on the account
@property (nullable, copy) NSNumber<Optional> *totalAbsoluteReturn;

// The total percentage return on the account
@property (nullable, copy) NSNumber<Optional> *totalPercentReturn;

// The base currency used in the account
@property (nullable, copy) NSString<Optional> *accountBaseCurrency;

// The marginCash balance on the account
@property (nullable,copy) NSNumber<Optional> *marginCash;

@end
