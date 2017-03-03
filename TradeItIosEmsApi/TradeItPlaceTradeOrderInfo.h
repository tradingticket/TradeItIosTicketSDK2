//
//  TradeItPlaceTradeOrderInfoResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/2/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"
#import "TradeItPlaceTradeOrderInfoPrice.h"

@interface TradeItPlaceTradeOrderInfo : TIEMSJSONModel<NSCopying>

/**
 *  The symbol passed into the order
 */
@property (nullable, copy) NSString *symbol;

/**
 *  The action passed into the order
 */
@property (nullable, copy) NSString *action;

/**
 *  The number of shares passed in the order
 */
@property (nullable, copy) NSNumber *quantity;

/**
 *  The expiration passed into order. Values are either Day or 'Good Till Cancelled'
 */
@property (nullable, copy) NSString *expiration;

/**
 *  Details about the price for the order just placed
 */
@property (nullable, copy) TradeItPlaceTradeOrderInfoPrice *price;

@end
