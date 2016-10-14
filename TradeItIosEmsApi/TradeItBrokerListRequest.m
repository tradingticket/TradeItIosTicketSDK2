//
//  TradeItBrokerListRequest.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 8/4/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItBrokerListRequest.h"

@implementation TradeItBrokerListRequest

-(id) initWithApiKey:(NSString *) apiKey{
    
    self = [super init];
    if (self) {
        self.apiKey = apiKey;
    }
    return self;
}

- (id) init{
    return [self initWithApiKey:@""];
}

@end
