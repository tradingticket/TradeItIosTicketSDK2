//
//  SerializedLinkedBrokerAccount.h
//  TradeItIosTicketSDK2
//
//  Created by Guillaume DEBAVELAERE on 17/08/2017.
//  Copyright © 2017 TradeIt. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "SerializedAccountOverview.h"
#import "SerializedFxAccountOverview.h"

@protocol SerializedLinkedBrokerAccount
@end

@interface SerializedLinkedBrokerAccount : JSONModel

@property (nonatomic) NSString *accountName;

@property (nonatomic) NSString *accountNumber;

@property (nonatomic) NSString *accountIndex;

@property (nonatomic) NSString *accountBaseCurrency;

@property (nonatomic) NSDate<Optional> *balanceLastUpdated;

@property (nonatomic) SerializedAccountOverview<Optional> *balance;

@property (nonatomic) SerializedFxAccountOverview<Optional> *fxBalance;

@property (nonatomic) BOOL isEnabled;

@end
