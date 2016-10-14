#import "TradeItRequest.h"
#import"TradeItAuthenticationInfo.h"

@interface TradeItUpdateLinkRequest : TradeItRequest

@property NSString *id;
@property NSString *password;
@property NSString *broker;
@property NSString *apiKey;
@property NSString *userId;

- (id)initWithUserId:(NSString *)userId
            authInfo:(TradeItAuthenticationInfo *)authInfo
              apiKey:(NSString *)apiKey;

@end
