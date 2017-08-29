#import "TradeItOAuthAccessTokenResult.h"

@implementation TradeItOAuthAccessTokenResult

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItOAuthAccessTokenResult: %@ broker=%@ brokerLongName=%@ ",[super description], self.broker, self.brokerLongName];
}

@end
