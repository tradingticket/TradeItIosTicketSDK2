//
//  TradeItAuthenticationRequest.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/28/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItAuthenticationRequest.h"

@implementation TradeItAuthenticationRequest

-(id) initWithUserToken:(NSString *) userToken userId:(NSString *) userId andApiKey:(NSString *) apiKey {
    self = [super init];
    if (self) {
        self.userToken = userToken;
        self.userId = userId;
        self.apiKey = apiKey;
    }
    
    return self;
}

@end
