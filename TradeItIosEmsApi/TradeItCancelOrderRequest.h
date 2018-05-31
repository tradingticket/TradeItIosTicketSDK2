#import "TradeItRequest.h"

@interface TradeItCancelOrderRequest : TradeItRequest

@property (nonatomic, copy, nullable) NSString * token;
@property (nonatomic, copy, nullable) NSString * accountNumber;
@property (nonatomic, copy, nullable) NSString * orderNumber;
@property (nonatomic, copy, nullable) NSString * interAppAddressCallback;

- (_Nonnull id)initWithInterAppAddressCallback:(NSString * _Nonnull)interAppAddressCallback;

@end
