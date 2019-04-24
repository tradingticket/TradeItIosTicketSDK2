#import "TradeItRequest.h"

@interface TradeItOAuthAccessTokenRequest : TradeItRequest

@property (copy, nonnull) NSString *apiKey;
@property (copy, nonnull) NSString *oAuthVerifier;

- (_Nonnull id)initWithApiKey:(NSString * _Nonnull)apiKey
       oAuthVerifier:(NSString * _Nonnull)oAuthVerifier;

@end
