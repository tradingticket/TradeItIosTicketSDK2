#import "TradeItAuthLinkResult.h"

@interface TradeItOAuthAccessTokenResult: TradeItAuthLinkResult

@property (nullable) NSString *broker;
@property (nullable) NSString *activationTime; // IMMEDIATE if there is no delay using the linked account, otherwise: ONE_OR_TWO_BUSINESS_DAY

@end
