#import "TradeItBrokerListRequest.h"

@implementation TradeItBrokerListRequest

- (id)initWithApiKey:(NSString *)apiKey{
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
    }

    return self;
}

- (id) init {
    return [self initWithApiKey:@""];
}

@end
