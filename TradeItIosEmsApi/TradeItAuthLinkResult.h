#import "TradeItResult.h"

@interface TradeItAuthLinkResult : TradeItResult

@property (nullable) NSString *userId;
@property (nullable) NSString *userToken;

- (NSString * _Nonnull)description;

@end
