#import "TradeItAuthenticationRequest.h"

@implementation TradeItAuthenticationRequest

-(id) initWithUserToken:(NSString *) userToken userId:(NSString *) userId andApiKey:(NSString *) apiKey andAdvertisingId:(NSString *) advertisingId {
    self = [super init];
    if (self) {
        self.userToken = userToken;
        self.userId = userId;
        self.apiKey = apiKey;
        self.advertisingId = advertisingId;
    }
    
    return self;
}

@end
