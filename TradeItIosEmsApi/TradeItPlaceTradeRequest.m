//
//  TradeItPlaceTradeRequest.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/31/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItPlaceTradeRequest.h"

@implementation TradeItPlaceTradeRequest

- (id)initWithOrderId:(NSString *) orderId {
    self = [super init];
    if (self) {
        self.orderId = orderId;
    }
    return self;
}

@end
