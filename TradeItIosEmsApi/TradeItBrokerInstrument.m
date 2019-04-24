#import "TradeItBrokerInstrument.h"

@implementation TradeItBrokerInstrument

- (NSString *)description {
    return [
        NSString stringWithFormat:@"[instrument=%@, isFeatured=%@, supportsAccountOverview=%@, supportsFxRates=%@, supportsOrderCanceling=%@, supportsOrderStatus=%@, supportsPositions=%@, supportsTrading=%@, supportsTransactionHistory=%@]",
        self.instrument,
        self.isFeatured ? @"true" : @"false",
        self.supportsAccountOverview ? @"true" : @"false",
        self.supportsFxRates ? @"true" : @"false",
        self.supportsOrderCanceling ? @"true" : @"false",
        self.supportsOrderStatus ? @"true" : @"false",
        self.supportsPositions ? @"true" : @"false",
        self.supportsTrading ? @"true" : @"false",
        self.supportsTransactionHistory ? @"true" : @"false"
    ];
}

@end
