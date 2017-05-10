//
//  TrasdeItBrokerListSuccessResult.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 8/4/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItResult.h"

@interface TradeItBrokerListResult : TradeItResult

@property (nullable, copy) NSArray *brokerList;

- (NSString * _Nonnull)description;
@end
