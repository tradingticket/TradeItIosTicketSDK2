//
//  TradeItTradeService.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/15/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItResult.h"
#import "TradeItSession.h"
#import "TradeItPreviewTradeRequest.h"
#import "TradeItPlaceTradeRequest.h"

@interface TradeItTradeService : NSObject

/**
 *  The session will need to be set for the request to be made
 */
@property TradeItSession *session;

/**
 *  As the session needs to be set, this is the preferred init method
 */
- (id)initWithSession:(TradeItSession *)session;

/**
 *  This method requires a TradeItPreviewTradeRequest
 *  We'll do some basic checking of the trade request before sending it
 *
 *  @return successful response is a TradeItPreviewTradeResult with review details that should be presented to the user
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 *  Error details can include information about how to change the order so it executes correctly, this can be things like
 *  some brokers only accept limit orders for OTC symbols, it's important to show the errors back to the user
 */
- (void)previewTrade:(TradeItPreviewTradeRequest *)order withCompletionBlock:(void (^)(TradeItResult *))completionBlock;


/**
 *  This method requires a TradeItPlaceTradeRequest
 *
 *  @return successful response is a TradeItPlaceTradeResult with placement details that should be presented to the user, such as the broker orderId
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 *
 */
- (void)placeTrade:(TradeItPlaceTradeRequest *)order withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

@end
