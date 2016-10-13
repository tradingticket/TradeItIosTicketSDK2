//
//  TradeItSuccessAuthenticationResult.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/14/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItAuthenticationResult.h"

@implementation TradeItAuthenticationResult

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItSuccessAuthenticationResult: %@ accounts=%@ ",
            [super description],
            self.accounts];
}

@end
