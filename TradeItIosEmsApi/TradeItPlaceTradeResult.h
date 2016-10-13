//
//  TradeItPlaceTradeResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/2/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItResult.h"
#import "TradeItPlaceTradeOrderInfo.h"

@interface TradeItPlaceTradeResult : TradeItResult

/**
 *  Message providing a recap of the order that was placed
 */
@property (nullable, copy) NSString<Optional> *confirmationMessage;

/**
 *  The order number returned by the broker
 */
@property (nullable, copy) NSString<Optional> *orderNumber;

/**
 *  Date the order was entered in US Eastern time
 */
@property (nullable, copy) NSString<Optional> *timestamp;

/**
 *  The broker the order was placed with
 */
@property (nullable, copy) NSString<Optional> *broker;

/**
 *  Details about the order just placed
 */
@property (nullable, copy) TradeItPlaceTradeOrderInfo<Optional> *orderInfo;

// The base currency used for the positions
@property (nullable, copy) NSString<Optional> *accountBaseCurrency;

@end
