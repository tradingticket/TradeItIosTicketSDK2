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

// TODO: Verify this change makes sense
@property (nullable, copy) NSArray<TradeItBrokerAccount> *accounts;

@end
