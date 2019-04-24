//
//  TradeItAuthLinkRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/25/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItRequest.h"
#import "TradeItAuthenticationInfo.h"

@interface TradeItAuthLinkRequest : TradeItRequest

@property NSString *id;
@property NSString *password;
@property NSString *broker;
@property NSString *apiKey;

- (id)initWithAuthInfo:(TradeItAuthenticationInfo *)authInfo
             andAPIKey:(NSString *)apiKey;

@end
