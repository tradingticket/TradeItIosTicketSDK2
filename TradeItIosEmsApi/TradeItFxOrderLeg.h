#include "TradeItRequest.h"

@protocol TradeItFxOrderLeg

@end

@interface TradeItFxOrderLeg : TradeItRequest

@property (nonatomic, copy) NSString *priceType;
@property (nonatomic, copy) NSString *pair;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSDecimalNumber *amount;
@property (nonatomic, copy) NSNumber<Optional> *rate;

@end
