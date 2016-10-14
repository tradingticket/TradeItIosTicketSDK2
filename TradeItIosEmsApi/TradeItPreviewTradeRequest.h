//
//  TradeItPreviewTradeRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/30/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItPreviewTradeRequest : TradeItRequest

// Set the accountNumber to trade in
@property (copy) NSString * accountNumber;

// Set the order symbol
@property (copy) NSString * orderSymbol;

// Set the type of the order, possible values are market, limit, stopMarket or stopLimit
@property (copy) NSString * orderPriceType;

// Set the order action, possible values are buy, sell, buyToCover, sellShort
@property (copy) NSString * orderAction;

// Set the order quantity
@property (copy) NSNumber * orderQuantity;

// Set the order expiration, possible values day, gtc
@property (copy) NSString * orderExpiration;

// Set limit price for limit, and stopLimit orders
@property (copy) NSNumber<Optional> * orderLimitPrice;

// Set stop price for stopLimit and and stopMarket
@property (copy) NSNumber<Optional> * orderStopPrice;





// Session Token - Will be set by the session associated with the request
// Setting this here will be overriden
@property (copy) NSString * token;

@end
