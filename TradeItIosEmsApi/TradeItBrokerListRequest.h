#import "TradeItRequest.h"

@interface TradeItBrokerListRequest : TradeItRequest

@property (copy) NSString *apiKey;

- (id)initWithApiKey:(NSString *)apiKey;

@end
