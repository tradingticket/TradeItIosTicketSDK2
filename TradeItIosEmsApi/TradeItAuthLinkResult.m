//
//  TradeItAuthLinkResult.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/25/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItAuthLinkResult.h"

@implementation TradeItAuthLinkResult

- (NSString *)description{
    return [NSString stringWithFormat:@"TradeItAuthLinkResult: %@ broker=%@ userId=%@ userToken=%@",[super description], self.broker, self.userId, self.userToken];
}

@end
