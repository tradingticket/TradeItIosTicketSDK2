#import "TradeItResult.h"
#import "TradeItUiBrokerConfig.h"

@interface TradeItUiConfigResult : TradeItResult

//@property(nonatomic, copy, nonnull) NSString* brokerId;
@property(nonatomic, copy, nonnull) NSDictionary<NSString *, TradeItUiBrokerConfig *> *uiBrokerConfigs;

@end
