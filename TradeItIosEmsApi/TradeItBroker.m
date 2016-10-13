//
//  TradeItBroker.m
//  TradeItIosEmsApi
//
//  Created by Alexander Kramer on 8/9/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItBroker.h"

@implementation TradeItBroker

- (id)initWithShortName:(NSString *)brokerShortName
               longName:(NSString *)brokerLongName {
    if( self = [super init] )
    {
        self.brokerShortName = brokerShortName;
        self.brokerLongName = brokerLongName;
    }

    return self;
}

@end
