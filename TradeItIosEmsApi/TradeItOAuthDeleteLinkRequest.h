#import "TradeItRequest.h"

@interface TradeItOAuthDeleteLinkRequest : TradeItRequest

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userToken;

- (id)initWithApiKey:(NSString *)apiKey
       userId:(NSString *)userId
       userToken:(NSString *)userToken;

@end
