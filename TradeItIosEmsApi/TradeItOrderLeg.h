#import <JSONModel/JSONModel.h>
#import "TradeItPriceInfo.h"
#import "TradeItOrderFill.h"

@class TradeItOrderStatusDetails;

@protocol TradeItOrderStatusDetails

@end

@protocol TradeItOrderLeg

@end

@interface TradeItOrderLeg : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional> * symbol;

@property (nonatomic, copy, nullable) NSNumber<Optional> * orderedQuantity;

@property (nonatomic, copy, nullable) NSNumber<Optional> * filledQuantity;

@property (nonatomic, copy, nullable) NSString<Optional> * action;

@property (nonatomic, copy, nullable) TradeItPriceInfo<Optional> * priceInfo;

@property (nonatomic, copy, nullable) NSArray<TradeItOrderFill*> <Optional, TradeItOrderFill> * fills;

@property (nonatomic, copy, nullable) NSArray<TradeItOrderStatusDetails*> <Optional, TradeItOrderStatusDetails>  * groupOrder;

@property (nonatomic, copy, nullable) NSString<Optional> * groupOrderId;

@end
