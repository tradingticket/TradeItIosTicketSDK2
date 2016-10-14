//
//  TradeItPlaceTradeRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/31/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItPlaceTradeRequest : TradeItRequest

- (id)initWithOrderId:(NSString *) orderId;

// The orderId as returned from the TradeItPreviewTradeRequest
@property (copy) NSString * orderId;


// Session Token - Will be set by the session associated with the request
// Setting this will be overriden
@property (copy) NSString * token;

@end
