#import "TradeItBrokerListRequest.h"

@implementation TradeItBrokerListRequest

- (id)initWithApiKey:(NSString *)apiKey
     userCountryCode:(NSString * _Nullable)countryCode {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.countryCode = countryCode;
    }

    return self;
}

@end
