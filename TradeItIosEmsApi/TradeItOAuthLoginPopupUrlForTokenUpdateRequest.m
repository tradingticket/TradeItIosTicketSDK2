#import "TradeItOAuthLoginPopupUrlForTokenUpdateRequest.h"

@implementation TradeItOAuthLoginPopupUrlForTokenUpdateRequest

- (id)initWithApiKey:(NSString *)apiKey
              broker:(NSString *)broker
              userId:(NSString *)userId
           userToken:(NSString *)userToken
interAppAddressCallback:(NSString *)interAppAddressCallback {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.broker = broker;
        self.userId = userId;
        self.userToken = userToken;
        self.interAppAddressCallback = interAppAddressCallback;
    }

    return self;
}

@end
