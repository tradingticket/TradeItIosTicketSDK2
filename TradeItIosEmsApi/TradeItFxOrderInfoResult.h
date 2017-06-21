#import <JSONModel/JSONModel.h>
#import "TradeItFxOrderLegResult.h"

@interface TradeItFxOrderInfoResult : JSONModel

@property (nonatomic, copy) NSString * _Nullable orderType;
@property (nonatomic, copy) NSString * _Nullable orderExpiration;
@property (nonatomic, copy) NSArray<TradeItFxOrderLegResult> * _Nonnull orderLegs;

@end
