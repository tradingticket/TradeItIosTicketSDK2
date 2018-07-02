#import "TradeItResult.h"
#import "TradeItCryptoPreviewTradeDetails.h"

@interface TradeItCryptoPreviewTradeResult : TradeItResult

@property (nonatomic, nonnull, copy) NSString *orderId;
@property (nonatomic, nonnull, copy) TradeItCryptoPreviewTradeDetails *orderDetails;

@end
