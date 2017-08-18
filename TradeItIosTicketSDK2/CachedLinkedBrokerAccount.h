//
//  CachedLinkedBrokerAccount.h
//  TradeItIosTicketSDK2
//
//  Created by Guillaume DEBAVELAERE on 17/08/2017.
//  Copyright © 2017 TradeIt. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CachedAccountOverview.h"
#import "CachedFxAccountOverview.h"

@protocol CachedLinkedBrokerAccount
@end

@interface CachedLinkedBrokerAccount : JSONModel

@property (nonatomic) NSString *accountName;

@property (nonatomic) NSString *accountNumber;

@property (nonatomic) NSString *accountIndex;

@property (nonatomic) NSString *accountBaseCurrency;

@property (nonatomic) NSDate<Optional> *balanceLastUpdated;

@property (nonatomic) CachedAccountOverview<Optional> *balance;

@property (nonatomic) CachedFxAccountOverview<Optional> *fxBalance;

@property (nonatomic) BOOL isEnabled;

@end
