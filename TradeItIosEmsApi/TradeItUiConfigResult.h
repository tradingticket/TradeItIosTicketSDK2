#import "TradeItResult.h"
#import "TradeItBrokerLogo.h"

@interface TradeItUiConfigResult : TradeItResult

@property(nonatomic, copy, nonnull) NSString* brokerId;
@property(nonatomic, copy, nonnull) NSArray<TradeItBrokerLogo> *logos;

@end
