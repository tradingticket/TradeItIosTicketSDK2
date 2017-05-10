//
//  TradeItAccountOverviewRequest.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/3/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItAccountOverviewRequest.h"

@implementation TradeItAccountOverviewRequest

-(id) initWithAccountNumber:(NSString *) accountNumber {
    self = [super init];
    if(self) {
        self.accountNumber = accountNumber;
    }
    return self;
}



@end
