//
//  TradeItSuccessAuthenticationResult.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/14/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItResult.h"
#import "TradeItBrokerAccount.h"

@interface TradeItAuthenticationResult : TradeItResult

@property (nullable, copy) NSArray<TradeItBrokerAccount, Optional> *accounts;

@end
