#import "TradeItRequest.h"
#import "TradeItFxOrderInfoInput.h"

@interface TradeItFxPlaceOrderRequest : TradeItRequest

@property (nonatomic, copy) NSString * _Nullable token;
@property (nonatomic, copy) NSString * _Nullable accountNumber;
@property (nonatomic) TradeItFxOrderInfoInput * _Nullable fxOrderInfoInput;

@end
