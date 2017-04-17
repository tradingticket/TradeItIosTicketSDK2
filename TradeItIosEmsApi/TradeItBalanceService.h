//
//  TradeItBalanceService.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/20/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItSession.h"
#import "TradeItAccountOverviewRequest.h"

@interface TradeItBalanceService : NSObject

/**
 *  The session will need to be set for the request to be made
 */
@property TradeItSession *session;

/**
 *  As the session needs to be set, this is the preferred init method
 */
- (id)initWithSession:(TradeItSession *)session;

/**
 *  This method requires a TradeItAccountOverviewRequest
 *
 *  @param completionBlock Completion callback where a successful response is a TradeItAccountOverviewResult.
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 *
 */
- (void)getAccountOverview:(TradeItAccountOverviewRequest *)request
       withCompletionBlock:(void (^)(TradeItResult *))completionBlock;


@end
