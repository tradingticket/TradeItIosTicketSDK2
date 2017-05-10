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
@property (nullable) NSString *broker;
@property (nullable) NSString *userId;
@property (nullable) NSString *keychainId;

- (nonnull id)initWithLabel:(NSString * _Nonnull)label
                     broker:(NSString * _Nonnull)broker
                     userId:(NSString * _Nonnull)userId
              andKeyChainId:(NSString * _Nonnull)keychainId;

@end
