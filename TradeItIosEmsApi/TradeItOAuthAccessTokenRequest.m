#import "TradeItOAuthAccessTokenRequest.h"

@implementation TradeItOAuthAccessTokenRequest

- (id)initWithApiKey:(NSString *)apiKey
       oAuthVerifier:(NSString *)oAuthVerifier {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.oAuthVerifier = oAuthVerifier;
    }

    return self;
}

@end
