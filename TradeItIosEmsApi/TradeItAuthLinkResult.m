#import "TradeItAuthLinkResult.h"

@implementation TradeItAuthLinkResult

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItAuthLinkResult: %@ userId=%@ userToken=%@",[super description], self.userId, self.userToken];
}

@end
