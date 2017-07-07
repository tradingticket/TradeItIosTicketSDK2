#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItAuthenticationRequest : TradeItRequest

@property NSString * userToken;
@property NSString * userId;
@property NSString * apiKey;
@property NSString * advertisingId;

-(id) initWithUserToken:(NSString *) userToken userId:(NSString *) userId andApiKey:(NSString *) apiKey andAdvertisingId:(NSString *) advertisingId;

@end
