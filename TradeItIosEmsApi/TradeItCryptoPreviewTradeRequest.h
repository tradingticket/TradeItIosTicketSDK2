#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2.h>

@interface TradeItCryptoPreviewTradeRequest : TradeItAuthenticatedRequest

@property (nonatomic, copy) NSString *accountNumber;
@property (nonatomic, copy) NSString *orderPair;
@property (nonatomic, copy) NSString *orderPriceType;
@property (nonatomic, copy) NSString *orderAction;
@property (nonatomic, copy) NSNumber *orderQuantity;
@property (nonatomic, copy) NSString *orderExpiration;
@property (nonatomic, copy) NSString *orderQuantityType;
@property (nonatomic, copy) NSNumber<Optional> *orderLimitPrice;
@property (nonatomic, copy) NSNumber<Optional> *orderStopPrice;

@end
