#import "TradeItUiConfigRequest.h"

@implementation TradeItUiConfigRequest

- (id)initWithApiKey:(NSString *)apiKey {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
    }

    return self;
}

@end
