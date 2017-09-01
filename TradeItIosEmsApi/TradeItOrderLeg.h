#import <JSONModel/JSONModel.h>
#import "TradeItPriceInfo.h"
#import "TradeItOrderFill.h"

@class TradeItOrderStatusDetails;

@protocol TradeItOrderStatusDetails

@end

@protocol TradeItOrderLeg

@end

@interface TradeItOrderLeg : JSONModel

@property (nonatomic, copy) NSString<Optional> * _Nullable symbol;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable orderedQuantity;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable filledQuantity;

@property (nonatomic, copy) NSString<Optional> * _Nullable action;

@property (nonatomic, copy) TradeItPriceInfo<Optional> * _Nullable priceInfo;

@property (nonatomic, copy) NSArray<TradeItOrderFill*> <Optional, TradeItOrderFill> * _Nullable fills;

@property (nonatomic, copy) NSArray<TradeItOrderStatusDetails*> <Optional, TradeItOrderStatusDetails>  * _Nullable groupOrder;

@property (nonatomic, copy) NSString<Optional> * _Nullable groupOrderId;

@end
