#import "TradeItBrokerListResult.h"

@implementation TradeItBrokerListResult

- (NSString *)description{
    return [NSString stringWithFormat:@"TrasdeItBrokerListSuccessResult: %@ brokerList=%@ ",[super description],self.brokerList];
}

@end
