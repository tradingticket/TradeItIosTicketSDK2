#import "TradeItRequest.h"

@interface TradeItOAuthAccessTokenRequest : TradeItRequest

@property (copy) NSString *apiKey;
@property (copy) NSString *oAuthVerifier;

- (id)initWithApiKey:(NSString *)apiKey
       oAuthVerifier:(NSString *)oAuthVerifier;

@end
