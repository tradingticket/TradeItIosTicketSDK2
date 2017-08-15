#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItAuthenticationRequest : TradeItRequest

@property (nonnull) NSString * userToken;
@property (nonnull) NSString * userId;
@property (nonnull) NSString * apiKey;
@property (nullable) NSString * advertisingId;

-(nonnull id) initWithUserToken:(NSString * _Nonnull) userToken userId:(NSString * _Nonnull) userId andApiKey:(NSString * _Nonnull) apiKey andAdvertisingId:(NSString * _Nullable) advertisingId;

@end
