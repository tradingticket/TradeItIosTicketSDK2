#import "TradeItRequest.h"

@interface TradeItCryptoQuoteRequest : TradeItRequest

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *accountNumber;
@property (nonatomic, copy) NSString *pair;

@end
