#import "TradeItResult.h"
#import "TradeItUiBrokerConfig.h"

@interface TradeItUiConfigResult : TradeItResult

@property (nonatomic, copy, nonnull) NSArray<TradeItUiBrokerConfig> *brokers;

@end
