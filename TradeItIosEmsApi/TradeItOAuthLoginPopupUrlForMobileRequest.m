#import "TradeItOAuthLoginPopupUrlForMobileRequest.h"

@implementation TradeItOAuthLoginPopupUrlForMobileRequest

- (id)initWithApiKey:(NSString *)apiKey
              broker:(NSString *)broker
interAppAddressCallback:(NSString *)interAppAddressCallback {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.broker = broker;
        self.interAppAddressCallback = interAppAddressCallback;
    }

    return self;
}

@end
