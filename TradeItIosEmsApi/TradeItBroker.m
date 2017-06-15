#import "TradeItBroker.h"

@implementation TradeItBroker

- (id)initWithShortName:(NSString *)brokerShortName
               longName:(NSString *)brokerLongName {
    if (self = [super init]) {
        self.shortName = brokerShortName;
        self.longName = brokerLongName;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"[TradeItBroker: shortName=%@ longName=%@ featuredStockBroker=%@ featuredFxBroker=%@ services=%@]",
            self.shortName,
            self.longName,
            self.featuredStockBroker ? @"true" : @"false",
            self.featuredFxBroker ? @"true" : @"false",
            self.services];
}

// Add backwards compatible getters #startuplyfe
- (NSString *)brokerShortName {
    return self.shortName;
}

- (NSString *)brokerLongName {
    return self.longName;
}

@end
