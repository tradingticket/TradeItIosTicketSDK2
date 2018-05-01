#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItCryptoSymbolsRequest : TradeItRequest
@property (nonatomic, copy, nonnull) NSString *accountNumber;
@property (nonatomic, copy, nonnull) NSString *token;
@end
