//
//  TradeItResult.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/23/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItResult.h"

@implementation TradeItResult


- (id)init {
    self = [super init];
    if (self) {
        self.token = nil;
        self.shortMessage = nil;
        self.longMessages = nil;
        self.status = nil;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"status=%@ token=%@ shortMessage=%@ longMessages%@",self.status, self.token, self.shortMessage, self.longMessages];
}
@end
