#import "TradeItRequest.h"

@interface TradeItOAuthLoginPopupUrlForMobileRequest : TradeItRequest

@property (copy) NSString *apiKey;
@property (copy) NSString *broker;
@property (copy) NSString *interAppAddressCallback;

- (id)initWithApiKey:(NSString *)apiKey
              broker:(NSString *)broker
interAppAddressCallback:(NSString *)interAppAddressCallback;

@end
