//
//  TradeItRequestAuthenticationInfo.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/17/15.
//  Copyright (c) 2015 Serge Kreiker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@interface TradeItAuthenticationInfo : TIEMSJSONModel<NSCopying>

/**
 * The user brokerage account login id
 * The API takes the same id field for all brokers, but some call it username, some call it user id, and some call it account number.\
 * When building a UI, you should use the same nomenclature brokers use. Below is a recap of what each broker uses for the id field.
 * - TD	User Id
 * - Etrade	User Id
 * - Scottrade	Account #
 * - Fidelity	Username
 * - Schwab	User Id
 * - TradeStation	Username
 * - Robinhood	Username
 * - OptionsHouse	User Id
 */
@property (copy) NSString *id;

/**
 *  The user brokerage account login password
 */
@property (copy) NSString *password;

/**
 *  The broker
 */
@property (copy) NSString *broker;


- (id) initWithId:(NSString *)id andPassword:(NSString*) password andBroker:(NSString *) broker;

@end
