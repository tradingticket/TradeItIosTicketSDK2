//
//  TradeItBrokerAccount.m
//  TradeItIosEmsApi
//
//  Created by Guillaume Debavelaere on 8/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItBrokerAccount.h"

@implementation TradeItBrokerAccount

- (id)initWithAccountBaseCurrency:(NSString *)accountBaseCurrency
                    accountNumber:(NSString *)accountNumber
                             name:(NSString *)name
                         tradable:(BOOL)tradable {
    if (self = [super init]) {
        self.accountBaseCurrency = accountBaseCurrency;
        self.accountNumber = accountNumber;
        self.name = name;
        self.tradable = tradable;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"accountBaseCurrency=%@ accountNumber=%@ accountName=%@ tradable=%d",
            self.accountBaseCurrency,
            self.accountNumber,
            self.name,
            self.tradable];
}

@end
