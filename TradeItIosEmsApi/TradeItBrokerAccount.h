//
//  TradeItBrokerAccount.h
//  TradeItIosEmsApi
//
//  Created by Guillaume Debavelaere on 8/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@protocol TradeItBrokerAccount
@end

@interface TradeItBrokerAccount :  TIEMSJSONModel<NSCopying>

@property (copy) NSString *accountBaseCurrency;

@property (copy) NSString *accountNumber;

@property (copy) NSString *name;

@property (assign, nonatomic) BOOL tradable;

- (id)initWithAccountBaseCurrency:(NSString *)accountBaseCurrency
                    accountNumber:(NSString *)accountNumber
                             name:(NSString *)name
                         tradable:(BOOL)tradable;

@end
