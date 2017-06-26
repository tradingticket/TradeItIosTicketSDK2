#import "TradeItRequest.h"

@interface TradeItOrderCapabilitiesRequest : TradeItRequest

@property (nonatomic, copy) NSString * _Nullable token;
@property (nonatomic, copy) NSString * _Nullable accountNumber;
@property (nonatomic, copy) NSString * _Nullable symbol;

@end
