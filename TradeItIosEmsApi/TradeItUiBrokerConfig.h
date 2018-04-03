#import <JSONModel/JSONModel.h>
#import "TradeItBrokerLogo.h"

@protocol TradeItUiBrokerConfig
@end

@interface TradeItUiBrokerConfig : JSONModel

@property(nonatomic, copy, nonnull) NSString* brokerId;
@property(nonatomic, copy, nonnull) NSArray<TradeItBrokerLogo> *logos;

@end
