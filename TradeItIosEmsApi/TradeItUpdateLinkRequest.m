#import "TradeItUpdateLinkRequest.h"

@implementation TradeItUpdateLinkRequest

- (id)initWithUserId:(NSString *)userId
            authInfo:(TradeItAuthenticationInfo *)authInfo
              apiKey:(NSString *)apiKey {

    self = [super init];

    if (self) {
        self.id = authInfo.id;
        self.password = authInfo.password;
        self.broker = authInfo.broker;
        self.apiKey = apiKey;
        self.userId = userId;
    }

    return self;
}

@end
