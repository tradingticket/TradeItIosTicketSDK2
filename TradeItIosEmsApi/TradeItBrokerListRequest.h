#import "TradeItRequest.h"

@interface TradeItBrokerListRequest : TradeItRequest

@property (copy) NSString * _Nonnull apiKey;
@property (copy) NSString<Optional> * _Nullable countryCode;

- (id _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey
     userCountryCode:(NSString * _Nullable)countryCode;

@end
