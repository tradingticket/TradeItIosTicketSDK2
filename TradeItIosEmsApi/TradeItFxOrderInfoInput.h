#include "TradeItFxOrderLeg.h"

@interface TradeItFxOrderInfoInput : TradeItRequest

@property (nonatomic, copy) NSString * _Nullable orderType;
@property (nonatomic, copy) NSString * _Nullable orderExpiration;
@property (nonatomic, copy) NSArray<TradeItFxOrderLeg> * _Nonnull orderLegs;

@end
