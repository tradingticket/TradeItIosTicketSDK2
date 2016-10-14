//
//  TradeItAdsRequest.m
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 4/27/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItAdsRequest.h"

@implementation TradeItAdsRequest

-(id) initWithApiKey:(NSString *)apiKey andBroker:(NSString *)broker {
    self = [super init];
    if(self) {
        self.apiKey = apiKey;
        self.broker = broker;
    }
    return self;
}

@end
