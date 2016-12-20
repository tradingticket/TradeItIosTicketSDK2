#import "TradeItAuthLinkResult.h"

@interface TradeItOAuthAccessTokenResult : TradeItAuthLinkResult

@property (nullable) NSString *userId;
@property (nullable) NSString *userToken;

@end
