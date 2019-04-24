#import "TradeItPlaceTradeResult.h"
#import "TradeItFxOrderInfoResult.h"

@interface TradeItFxPlaceOrderResult : TradeItResult

@property (nonatomic, copy) NSString * _Nullable confirmationMessage;
@property (nonatomic, copy) NSString * _Nullable timestamp;
@property (nonatomic, copy) NSString * _Nullable broker;
@property (nonatomic, copy) NSString * _Nullable accountBaseCurrency;
@property (nonatomic, copy) TradeItFxOrderInfoResult * _Nullable orderInfoOutput;

@end
