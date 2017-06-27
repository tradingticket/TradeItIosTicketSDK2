#import "TradeItBrokerInstrument.h"

@implementation TradeItBrokerInstrument

- (NSString *)description {
    return [
        NSString stringWithFormat:@"[instrument=%@, balance=%@, cancel=%@, isFeatured=%@, orderStatus=%@, positions=%@, quote=%@, trade=%@, transactions=%@]",
        self.instrument,
        self.balance ? @"true" : @"false",
        self.cancel ? @"true" : @"false",
        self.isFeatured ? @"true" : @"false",
        self.orderStatus ? @"true" : @"false",
        self.positions ? @"true" : @"false",
        self.quote ? @"true" : @"false",
        self.trade ? @"true" : @"false",
        self.transactions ? @"true" : @"false"
    ];
}

@end
