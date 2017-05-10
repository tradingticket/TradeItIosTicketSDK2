//
//  TradeItMarketDataService.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItSession.h"
#import "TradeItQuotesRequest.h"
#import "TradeItSymbolLookupRequest.h"

@interface TradeItMarketDataService : NSObject

/**
 *  The session will need to be set for the request to be made
 */
@property TradeItConnector *connector;

/**
 *  As the connector needs to be set, this is the preferred init method
 */
- (id)initWithConnector:(TradeItConnector *)connector;

/**
 *  This method requires a TradeItQuoteRequest
 *
 *  @param completionBlock Completion callback where a successful response is a TradeItQuoteResult.
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 *
 */
- (void)getQuoteData:(TradeItQuotesRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

/**
 *  This method requires a TradeItSymbolLookupRequest
 *
 *  @param completionBlock Completion callback where a successful response is a TradeItSymbolLookupResult.
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 *
 */
- (void)symbolLookup:(TradeItSymbolLookupRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock;


@end
