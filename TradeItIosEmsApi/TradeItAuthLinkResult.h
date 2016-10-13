//
//  TradeItAuthLinkResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/25/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItResult.h"

@interface TradeItAuthLinkResult : TradeItResult

@property (nullable) NSString *userId;
@property (nullable) NSString *userToken;

- (NSString *)description;

@end
