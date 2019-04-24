//
//  TradeItAuthLinkRequest.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/25/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItAuthLinkRequest.h"

@implementation TradeItAuthLinkRequest

- (id)initWithAuthInfo:(TradeItAuthenticationInfo *)authInfo
             andAPIKey:(NSString *)apiKey {
    self = [super init];

    if (self) {
        self.id = authInfo.id;
        self.password = authInfo.password;
        self.broker = authInfo.broker;
        self.apiKey = apiKey;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItAuthenticationInfo: id:%@ password:%@  Broker:%@, APIKey:%@", self.id, self.password, self.broker, self.apiKey];
}

- (id)copyWithZone:(NSZone *) __unused zone
{
    TradeItAuthenticationInfo * authInfo = [[TradeItAuthenticationInfo alloc] initWithId:self.id andPassword:self.password andBroker:self.broker];
    id copy = [[[self class] alloc] initWithAuthInfo:authInfo andAPIKey:self.apiKey];
    return copy;
}

@end
