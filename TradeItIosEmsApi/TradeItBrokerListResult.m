#import "TradeItBrokerListResult.h"

@implementation TradeItBrokerListResult

- (NSString *)description{
    return [
        NSString stringWithFormat:@"[TradeItBrokerListSuccessResult: %@, featuredBrokerLabel=%@, brokerList=%@]",
        [super description],
        self.featuredBrokerLabel,
        self.brokerList
    ];
}

@end
