#import "TradeItResult.h"
#import "TradeItBroker.h"

@interface TradeItBrokerListResult : TradeItResult

@property (nullable, copy) NSArray<TradeItBroker> *brokerList;
@property (nullable, nonatomic) NSString <Optional> *featuredBrokerLabel;

- (NSString * _Nonnull)description;

@end
