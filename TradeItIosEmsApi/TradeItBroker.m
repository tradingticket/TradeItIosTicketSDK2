#import "TradeItBroker.h"

@implementation TradeItBroker

- (NSString *)description {
    return [NSString stringWithFormat: @"[TradeItBroker: shortName=%@ longName=%@ featuredStockBroker=%@ featuredFxBroker=%@ services=%@]",
            self.shortName,
            self.longName,
            self.featuredStockBroker ? @"true" : @"false",
            self.featuredFxBroker ? @"true" : @"false",
            self.services];
}

// Add backwards compatible getters :(
- (NSString *)brokerShortName {
    return self.shortName;
}

- (NSString *)brokerLongName {
    return self.longName;
}


@end
