//
//  TradeItPublisherService.h
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 4/27/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItSession.h"
#import "TradeItPublisherDataRequest.h"
#import "TradeItBrokerCenterResult.h"
#import "TradeItPublisherDataResult.h"

@interface TradeItPublisherService : NSObject

/**
 *  The session will need to be set for the request to be made
 */
@property TradeItConnector *connector;

- (id)initWithConnector:(TradeItConnector *)connector;

- (void)getBrokerCenter:(TradeItPublisherDataRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock;
- (void)getPublisherData:(TradeItPublisherDataRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

@end
