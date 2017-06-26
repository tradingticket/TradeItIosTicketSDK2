//
//  TradeItBrokerAccount.h
//  TradeItIosEmsApi
//
//  Created by Guillaume Debavelaere on 8/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TradeItInstrumentOrderCapabilities.h"

@protocol TradeItBrokerAccount
@end

@interface TradeItBrokerAccount :  JSONModel<NSCopying>

@property (copy) NSString *accountBaseCurrency;

@property (copy) NSString *accountNumber;

@property (copy) NSString *name;

@property (assign, nonatomic) BOOL tradable;

@property (nonatomic, copy) NSArray<TradeItInstrumentOrderCapabilities> *orderCapabilities;

- (id)initWithAccountBaseCurrency:(NSString *)accountBaseCurrency
                    accountNumber:(NSString *)accountNumber
                             name:(NSString *)name
                         tradable:(BOOL)tradable;

@end
