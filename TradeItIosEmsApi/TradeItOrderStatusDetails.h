#import <JSONModel/JSONModel.h>
#import "TradeItOrderLeg.h"

@interface TradeItOrderStatusDetails : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional>  * orderNumber;

@property (nonatomic, copy, nullable) NSString<Optional>  * orderExpiration;

@property (nonatomic, copy, nullable) NSString<Optional>  * orderType;

@property (nonatomic, copy, nullable) NSString<Optional>  * orderStatus;

@property (nonatomic, copy, nullable) NSArray<TradeItOrderLeg*> <Optional, TradeItOrderLeg> * orderLegs;

@property (nonatomic, copy, nullable) NSString<Optional>  * groupOrderId;

@property (nonatomic, copy, nullable) NSString<Optional>  * groupOrderType;

@property (nonatomic, copy, nullable) NSArray<TradeItOrderStatusDetails*> <Optional, TradeItOrderStatusDetails>  * groupOrders;

@end
