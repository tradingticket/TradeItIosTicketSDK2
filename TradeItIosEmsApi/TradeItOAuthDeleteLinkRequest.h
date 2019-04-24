#import "TradeItRequest.h"

@interface TradeItOAuthDeleteLinkRequest : TradeItRequest

@property (nonatomic, copy, nonnull) NSString *apiKey;
@property (nonatomic, copy, nonnull) NSString *userId;
@property (nonatomic, copy, nullable) NSString *userToken;

- (_Nonnull id)initWithApiKey:(NSString * _Nonnull)apiKey
       userId:(NSString * _Nonnull)userId
       userToken:(NSString * _Nullable)userToken;

@end
