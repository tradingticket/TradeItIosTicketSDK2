#import <JSONModel/JSONModel.h>
#import "TradeItPreviewMessage.h"

/**
 *  Class containing the Order details contained in the TradeItStockOrEtfTradeReviewResult
 */
@interface TradeItPreviewTradeOrderDetails : JSONModel<NSCopying>

/**
 *  The symbol passed into the order
 */
@property (nonatomic, nonnull, copy) NSString *orderSymbol;

/**
 *  The action passed into the order
 */
@property (nonatomic, nonnull, copy) NSString *orderAction;

/**
 *  The number of shares passed in the order
 */
@property (nonatomic, nonnull, copy) NSNumber *orderQuantity;

@property (nonatomic, nonnull, copy) NSString *orderQuantityType;

/**
 *  The expiration passed into order. Values are either Day or 'Good Till Cancelled'
 */
@property (nonatomic, nonnull, copy) NSString *orderExpiration;

/**
 *  The price at which the order will execute, contains:
 *  "Market" for market orders
 *  <limit price> for limit orders (i.e. 34.56)
 *  <stop price>  for stop market orders (i.e 30.67)
 *  <stop limit price> (trigger:<stop price>) for stop limit orders (i.e 34.56(trigger:30.67) )
 */
@property (nonatomic, nonnull, copy) NSString *orderPrice;

/**
 *  "Estimated Proceeds" or "Estimated Cost" depending on the order action
 */
@property (nonatomic, nonnull, copy) NSString *orderValueLabel;

@property (nonatomic, nonnull, copy) NSString *orderCommissionLabel;

/**
 *  A user friendly description of the order. i.e "You are about to place a market order to buy AAPL" or "You are about to place a limit order to sell short AAPL"
 */
@property (nonatomic, nonnull, copy) NSString *orderMessage;

/**
 *  Quote from the broker, last trade price
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *lastPrice;

/**
 *  Quote from the broker, bid price
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *bidPrice;

/**
 *  Quote from the broker, ask price
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *askPrice;

/**
 *  Quote from the broker, timestamp is ET
 */
@property (nonatomic, nullable, copy) NSString<Optional> *timestamp;

/**
 *  The user buying power (pre-trade)
 *  Note: Tradestation returns buyingPower for all account types.
 *  Other brokers return buyingPower for margin accounts and availableCash for cash accounts
 *  If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *buyingPower;

/**
 *  The user's available cash (to withdraw). If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *availableCash;

/**
 *  The number of shares held long by the user (pre-trade)
 *  If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *longHoldings;

/**
 *  The number of shares held short by the user (pre-trade)
 *  If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *shortHoldings;

/**
 *  Estimated value of the order, does not include fees.
 *  If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *estimatedOrderValue;


/**
 *  The estimated cost of fees and commissions for the order.
 *  If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *estimatedOrderCommission;


/**
 *  The estimated total cost of the order including fees.
 *  If nil ignore field as not available
 */
@property (nonatomic, nullable, copy) NSNumber<Optional> *estimatedTotalValue;

@property (nonatomic) BOOL userDisabledMargin;

@property (nonatomic, nullable, copy) NSArray<TradeItPreviewMessage *> <Optional, TradeItPreviewMessage> *warnings;

@end
