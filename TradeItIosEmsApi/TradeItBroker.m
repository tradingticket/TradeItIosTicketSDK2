#import "TradeItBroker.h"

@implementation TradeItBroker

- (NSString *)description {
    return [NSString stringWithFormat: @"[TradeItBroker: shortName=%@, longName=%@, brokerInstruments=%@]",
            self.shortName,
            self.longName,
            self.brokerInstruments];
}

// Add backwards compatible getters :(
- (NSString *)brokerShortName {
    return self.shortName;
}

- (NSString *)brokerLongName {
    return self.longName;
}

@end
