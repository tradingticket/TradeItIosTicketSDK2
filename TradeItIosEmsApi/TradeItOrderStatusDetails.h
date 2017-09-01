#import <JSONModel/JSONModel.h>
#import "TradeItOrderLeg.h"

@interface TradeItOrderStatusDetails : JSONModel

@property (nonatomic, copy) NSString<Optional>  * _Nullable orderNumber;

@property (nonatomic, copy) NSString<Optional>  * _Nullable orderExpiration;

@property (nonatomic, copy) NSString<Optional>  * _Nullable orderType;

@property (nonatomic, copy) NSString<Optional>  * _Nullable orderStatus;

@property (nonatomic, copy) NSArray<TradeItOrderLeg*> <Optional, TradeItOrderLeg> * _Nullable orderLegs;


@end
