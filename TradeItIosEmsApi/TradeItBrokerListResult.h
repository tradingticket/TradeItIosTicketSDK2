#import "TradeItResult.h"
#import "TradeItBroker.h"

@interface TradeItBrokerListResult : TradeItResult

@property (nullable, nonatomic, copy) NSArray<TradeItBroker> *brokerList;
@property (nullable, nonatomic) NSString <Optional> *featuredBrokerLabel;
@property (nullable, nonatomic) NSString <Optional> *welcomePromotionText;
@property (nullable, nonatomic) NSString <Optional> *welcomePromotionUrl;

- (NSString * _Nonnull)description;

@end
