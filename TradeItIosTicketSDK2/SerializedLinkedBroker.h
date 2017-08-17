//
//  SerializedLinkedBroker.h
//  TradeItIosTicketSDK2
//
//  Created by Guillaume DEBAVELAERE on 17/08/2017.
//  Copyright © 2017 TradeIt. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "SerializedLinkedBroker.h"
#import "SerializedLinkedBrokerAccount.h"

@interface SerializedLinkedBroker : JSONModel

@property (nonatomic) NSArray<SerializedLinkedBrokerAccount*> <SerializedLinkedBrokerAccount> *accounts;

@property (nonatomic) NSDate<Optional> *accountsLastUpdated;

@property (nonatomic) BOOL isAccountLinkDelayedError;

@end
