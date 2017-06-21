#include "TradeItRequest.h"

@protocol TradeItFxOrderLeg

@end

@interface TradeItFxOrderLeg : TradeItRequest

@property (nonatomic, copy) NSString *priceType;
@property (nonatomic, copy) NSString *pair;
@property (nonatomic, copy) NSString *action;
@property (nonatomic) NSInteger amount;

@end
