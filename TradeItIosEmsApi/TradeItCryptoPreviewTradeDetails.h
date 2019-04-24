#import <JSONModel/JSONModel.h>
#import "TradeItPreviewMessage.h"

@protocol TradeItCryptoPreviewTradeDetails
@end

@interface TradeItCryptoPreviewTradeDetails : JSONModel

@property (nonatomic, nonnull, copy) NSString *orderPair;
@property (nonatomic, nonnull, copy) NSString *orderAction;
@property (nonatomic, nonnull, copy) NSString *orderPriceType;
@property (nonatomic, nonnull, copy) NSString *orderExpiration;
@property (nonatomic, nonnull, copy) NSNumber *orderQuantity;
@property (nonatomic, nonnull, copy) NSString *orderQuantityType;
@property (nonatomic, nonnull, copy) NSString *orderCommissionLabel;
@property (nonatomic, nullable, copy) NSNumber<Optional> *orderLimitPrice;
@property (nonatomic, nullable, copy) NSNumber<Optional> *orderStopPrice;
@property (nonatomic, nullable, copy) NSNumber<Optional> *estimatedOrderValue;
@property (nonatomic, nullable, copy) NSNumber<Optional> *estimatedOrderCommission;
@property (nonatomic, nullable, copy) NSNumber<Optional> *estimatedTotalValue;
@property (nonatomic, nullable, copy) NSArray<TradeItPreviewMessage *> <Optional, TradeItPreviewMessage> *warnings;

@end
