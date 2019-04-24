#import <Foundation/Foundation.h>
#import "TradeItAuthenticatedRequest.h"

@interface TradeItPreviewTradeRequest : TradeItAuthenticatedRequest

@property (nonatomic, copy) NSString *accountNumber;
@property (nonatomic, copy) NSString *orderSymbol;
@property (nonatomic, copy) NSString *orderPriceType;
@property (nonatomic, copy) NSString *orderAction;
@property (nonatomic, copy) NSNumber *orderQuantity;
@property (nonatomic, copy) NSString *orderQuantityType;
@property (nonatomic, copy) NSString *orderExpiration;
@property (nonatomic, copy) NSNumber<Optional> *orderLimitPrice;
@property (nonatomic, copy) NSNumber<Optional> *orderStopPrice;
@property (nonatomic) BOOL userDisabledMargin;

@end
