#import "TradeItResult.h"
#import "TradeItBroker.h"

@interface TradeItBrokerListResult : TradeItResult

@property (nullable, copy) NSArray<TradeItBroker> *brokerList;

- (NSString * _Nonnull)description;

@end
