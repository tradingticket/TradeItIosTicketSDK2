#import "TradeItRequest.h"

@interface TradeItOAuthLoginPopupUrlForMobileRequest : TradeItRequest

@property (copy, nonnull) NSString *apiKey;
@property (copy, nonnull) NSString *broker;
@property (copy, nonnull) NSString *interAppAddressCallback;

- (_Nonnull id)initWithApiKey:(NSString * _Nonnull)apiKey
              broker:(NSString * _Nonnull)broker
interAppAddressCallback:(NSString * _Nonnull)interAppAddressCallback;

@end
