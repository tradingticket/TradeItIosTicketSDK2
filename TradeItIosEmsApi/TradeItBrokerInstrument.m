#import "TradeItBrokerInstrument.h"

@implementation TradeItBrokerInstrument

- (NSString *)description {
    return [
        NSString stringWithFormat:@"[instrument=%@, supportsAccountOverview=%@, supportsOrderCanceling=%@, isFeatured=%@, supportsOrderStatus=%@, supportsPositions=%@, supportsFxRates=%@, supportsTrading=%@, supportsTransactionHistory=%@]",
        self.instrument,
        self.supportsAccountOverview ? @"true" : @"false",
        self.supportsOrderCanceling ? @"true" : @"false",
        self.isFeatured ? @"true" : @"false",
        self.supportsOrderStatus ? @"true" : @"false",
        self.supportsPositions ? @"true" : @"false",
        self.supportsFxRates ? @"true" : @"false",
        self.supportsTrading ? @"true" : @"false",
        self.supportsTransactionHistory ? @"true" : @"false"
    ];
}

@end
