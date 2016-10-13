//
//  TradeItLinkedLogin.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/28/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItAuthLinkResult.h"

@interface TradeItLinkedLogin : NSObject

@property (nullable) NSString *label;
@property NSString *broker;
@property NSString *userId;
@property NSString *keychainId;

-(id) initWithLabel:(NSString *) label broker:(NSString *) broker userId:(NSString *) userId andKeyChainId:(NSString *) keychainId;

@end
