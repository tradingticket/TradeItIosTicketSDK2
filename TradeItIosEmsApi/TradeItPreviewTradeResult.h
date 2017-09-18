//
//  TradeItPreviewTradeResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/30/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItResult.h"
#import "TradeItPreviewTradeOrderDetails.h"
#import "TradeItPreviewDocument.h"

@interface TradeItPreviewTradeResult : TradeItResult

/**
 *  An array containing all the warnings returned by the broker
 */
@property (nullable, copy) NSArray<Optional> *warningsList;

/**
 *  An array containing all the warnings that need to be acknowledged by the user. Should be displayed to the user with a checkbox asking him to review and acknowledge the following warnings before placing the order.
 */
@property (nullable, copy) NSArray<Optional> *ackWarningsList;

@property (nonatomic, copy, nullable) NSArray<TradeItPreviewDocument*> <Optional, TradeItPreviewDocument> * documentList;

/**
 *  A TradeIt internal orderId used to reference the preview order, needed to place the order
 */
@property (nonnull, copy) NSString *orderId;

/**
 *  An Object with order details. @see TradeItStockOrEtfTradeReviewOrderDetails
 */
@property (nullable, copy) TradeItPreviewTradeOrderDetails *orderDetails;

// The base currency used for the positions
@property (nullable, copy) NSString<Optional> *accountBaseCurrency;

@end
