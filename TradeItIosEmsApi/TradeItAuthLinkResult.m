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
    return [NSString stringWithFormat:@"TradeItAuthLinkResult: %@ userId=%@  userToken=%@",[super description],self.userId, self.userToken];
}

@end
