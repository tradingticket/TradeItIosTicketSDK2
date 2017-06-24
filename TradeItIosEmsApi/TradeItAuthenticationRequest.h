//
//  TradeItAuthenticationRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/28/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItAuthenticationRequest : TradeItRequest

@property NSString * userToken;
@property NSString * userId;
@property NSString * apiKey;
@property NSString * advertisingId;
@property BOOL returnOrderCapabilities;

-(id) initWithUserToken:(NSString *) userToken userId:(NSString *) userId andApiKey:(NSString *) apiKey andAdvertisingId:(NSString *) advertisingId;

@end
