#import <JSONModel/JSONModel.h>
#import "TradeItOrderLeg.h"

@interface TradeItOrderStatusDetails : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional>  * orderNumber;

@property (nonatomic, copy, nullable) NSString<Optional>  * orderExpiration;

@property (nonatomic, copy, nullable) NSString<Optional>  * orderType;

@property (nonatomic, copy, nullable) NSString<Optional>  * orderStatus;

@property (nonatomic, copy, nullable) NSArray<TradeItOrderLeg*> <Optional, TradeItOrderLeg> * orderLegs;


@end
