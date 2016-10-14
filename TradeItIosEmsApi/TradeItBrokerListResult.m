//
//  TrasdeItBrokerListSuccessResult.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 8/4/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItBrokerListResult.h"

@implementation TradeItBrokerListResult

- (NSString *)description{
    return [NSString stringWithFormat:@"TrasdeItBrokerListSuccessResult: %@ brokerList=%@ ",[super description],self.brokerList];
}

@end
