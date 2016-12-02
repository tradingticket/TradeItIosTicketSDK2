#import "TradeItOAuthLoginPopupUrlForTokenUpdateRequest.h"

@implementation TradeItOAuthLoginPopupUrlForTokenUpdateRequest

- (id)initWithApiKey:(NSString *)apiKey
              broker:(NSString *)broker
              userId:(NSString *)userId
interAppAddressCallback:(NSString *)interAppAddressCallback {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.broker = broker;
        self.userId = userId;
        self.interAppAddressCallback = interAppAddressCallback;
    }

    return self;
}

@end
