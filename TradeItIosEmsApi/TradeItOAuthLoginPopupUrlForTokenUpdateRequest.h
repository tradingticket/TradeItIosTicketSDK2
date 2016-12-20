#import "TradeItRequest.h"

@interface TradeItOAuthLoginPopupUrlForTokenUpdateRequest : TradeItRequest

@property (copy) NSString *apiKey;
@property (copy) NSString *broker;
@property (copy) NSString *userId;
@property (copy) NSString *interAppAddressCallback;

- (id)initWithApiKey:(NSString *)apiKey
              broker:(NSString *)broker
              userId:(NSString *)userId
interAppAddressCallback:(NSString *)interAppAddressCallback;

@end
