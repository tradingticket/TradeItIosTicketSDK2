#import "TradeItOAuthDeleteLinkRequest.h"

@implementation TradeItOAuthDeleteLinkRequest

- (id)initWithApiKey:(NSString *)apiKey
       userId:(NSString *)userId
       userToken:(NSString *)userToken {
    self = [super init];
    
    if (self) {
        self.apiKey = apiKey;
        self.userId = userId;
        self.userToken = userToken;
    }
    
    return self;
}

@end
