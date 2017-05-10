#import "TradeItOAuthAccessTokenResult.h"

@implementation TradeItOAuthAccessTokenResult

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItOAuthAccessTokenResult: %@ broker=%@ ",[super description], self.broker];
}

@end
