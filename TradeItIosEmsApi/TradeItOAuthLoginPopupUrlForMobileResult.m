#import "TradeItOAuthLoginPopupUrlForMobileResult.h"

@implementation TradeItOAuthLoginPopupUrlForMobileResult

- (NSURL *)oAuthUrl {
    if (self.oAuthURL == NULL) {
        return NULL;
    }

    return [[NSURL alloc] initWithString:self.oAuthURL];
}

@end
