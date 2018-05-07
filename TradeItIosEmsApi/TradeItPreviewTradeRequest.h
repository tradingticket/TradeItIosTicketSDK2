#import <Foundation/Foundation.h>
#import "TradeItAuthenticatedRequest.h"

@interface TradeItPreviewTradeRequest : TradeItAuthenticatedRequest

// Set the accountNumber to trade in
@property (nonatomic, copy) NSString * accountNumber;

// Set the order symbol
@property (nonatomic, copy) NSString * orderSymbol;

// Set the type of the order, possible values are market, limit, stopMarket or stopLimit
@property (nonatomic, copy) NSString * orderPriceType;

// Set the order action, possible values are buy, sell, buyToCover, sellShort
@property (nonatomic, copy) NSString * orderAction;

// Set the order quantity
@property (nonatomic, copy) NSNumber * orderQuantity;

// Set the order expiration, possible values day, gtc
@property (nonatomic, copy) NSString * orderExpiration;

// Set limit price for limit, and stopLimit orders
@property (nonatomic, copy) NSNumber<Optional> * orderLimitPrice;

// Set stop price for stopLimit and and stopMarket
@property (nonatomic, copy) NSNumber<Optional> * orderStopPrice;

// Session Token - Will be set by the session associated with the request
// Setting this here will be overriden
@property (nonatomic, copy) NSString * token;

@property (nonatomic) BOOL userDisabledMargin;

@end
