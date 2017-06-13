#import "TradeItBroker.h"

@implementation TradeItBroker

- (id)initWithShortName:(NSString *)brokerShortName
               longName:(NSString *)brokerLongName {
    if (self = [super init]) {
        self.brokerShortName = brokerShortName;
        self.brokerLongName = brokerLongName;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"[TradeItBroker: brokerShortName=%@ brokerLongName=%@ featured=%@ services=%@]",
            self.brokerShortName,
            self.brokerLongName,
            self.featured ? @"true" : @"false",
            self.services];
}

@end
