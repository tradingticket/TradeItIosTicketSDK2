//
//  CachedLinkedBroker.h
//  TradeItIosTicketSDK2
//
//  Created by Guillaume DEBAVELAERE on 17/08/2017.
//  Copyright © 2017 TradeIt. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CachedLinkedBroker.h"
#import "CachedLinkedBrokerAccount.h"

@interface CachedLinkedBroker : JSONModel

@property (nonatomic) NSArray<CachedLinkedBrokerAccount*> <CachedLinkedBrokerAccount> *accounts;

@property (nonatomic) NSDate<Optional> *accountsLastUpdated;

@property (nonatomic) BOOL isAccountLinkDelayedError;

@end
