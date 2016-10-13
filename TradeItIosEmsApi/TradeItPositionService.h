//
//  TradeItPositionService.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/20/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItSession.h"
#import "TradeItGetPositionsRequest.h"

@interface TradeItPositionService : NSObject

/**
 *  The session will need to be set for the request to be made
 */
@property TradeItSession * session;

/**
 *  As the session needs to be set, this is the preferred init method
 */
-(id) initWithSession:(TradeItSession *) session;

/**
 *  This method requires a TradeItGetPositionsRequest
 *
 *  @return successful response is a TradeItGetPositionsResults
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 *
 */
- (void) getAccountPositions:(TradeItGetPositionsRequest *) request withCompletionBlock:(void (^)(TradeItResult *)) completionBlock;


@end
