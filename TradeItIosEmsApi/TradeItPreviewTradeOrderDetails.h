//
//  TradeItStockOrEtfTradeReviewOrderDetails.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/23/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TIEMSJSONModel.h"
/**
 *  Class containing the Order details contained in the TradeItStockOrEtfTradeReviewResult
 */
@interface TradeItPreviewTradeOrderDetails : TIEMSJSONModel<NSCopying>

/**
 *  The symbol passed into the order
 */
@property (nonnull, copy) NSString *orderSymbol;

/**
 *  The action passed into the order
 */
@property (nonnull, copy) NSString *orderAction;

/**
 *  The number of shares passed in the order
 */
@property (nonnull, copy) NSNumber *orderQuantity;

/**
 *  The expiration passed into order. Values are either Day or 'Good Till Cancelled'
 */
@property (nonnull, copy) NSString *orderExpiration;

/**
 *  The price at which the order will execute, contains:
 *  "Market" for market orders
 *  <limit price> for limit orders (i.e. 34.56)
 *  <stop price>  for stop market orders (i.e 30.67)
 *  <stop limit price> (trigger:<stop price>) for stop limit orders (i.e 34.56(trigger:30.67) )
 */
@property (nonnull, copy) NSString *orderPrice;

/**
 *  "Estimated Proceeds" or "Estimated Cost" depending on the order action
 */
@property (nonnull, copy) NSString *orderValueLabel;

/**
 *  A user friendly description of the order. i.e "You are about to place a market order to buy AAPL" or "You are about to place a limit order to sell short AAPL"
 */
@property (nonnull, copy) NSString *orderMessage;

/**
 *  Quote from the broker, last trade price
 */
@property (nullable, copy) NSNumber<Optional> *lastPrice;

/**
 *  Quote from the broker, bid price
 */
@property (nullable, copy) NSNumber<Optional> *bidPrice;

/**
 *  Quote from the broker, ask price
 */
@property (nullable, copy) NSNumber<Optional> *askPrice;

/**
 *  Quote from the broker, timestamp is ET
 */
@property (nullable, copy) NSString<Optional> *timestamp;

/**
 *  The user buying power (pre-trade)
 *  Note: Tradestation returns buyingPower for all account types.
 *  Other brokers return buyingPower for margin accounts and availableCash for cash accounts
 *  If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *buyingPower;

/**
 *  The user's available cash (to withdraw). If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *availableCash;

/**
 *  The number of shares held long by the user (pre-trade)
 *  If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *longHoldings;

/**
 *  The number of shares held short by the user (pre-trade)
 *  If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *shortHoldings;

/**
 *  Estimated value of the order, does not include fees.
 *  If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *estimatedOrderValue;


/**
 *  The estimated cost of fees and commissions for the order.
 *  If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *estimatedOrderCommission;


/**
 *  The estimated total cost of the order including fees.
 *  If nil ignore field as not available
 */
@property (nullable, copy) NSNumber<Optional> *estimatedTotalValue;

@end
