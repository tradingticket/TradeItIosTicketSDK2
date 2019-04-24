#import "TradeItUiConfigResult.h"

@implementation TradeItUiConfigResult


-(id)init {
    if (self = [super init])  {
        self.brokers = [NSArray<TradeItUiBrokerConfig> new];
    }

    return self;
};

@end
