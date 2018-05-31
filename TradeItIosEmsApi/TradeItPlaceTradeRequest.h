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

- (id _Nonnull)initWithOrderId:(NSString * _Nonnull) orderId
    andInterAppAddressCallback:(NSString * _Nonnull) interAppAddressCallback;

// The orderId as returned from the TradeItPreviewTradeRequest
@property (copy) NSString * _Nullable orderId;


// Session Token - Will be set by the session associated with the request
// Setting this will be overriden
@property (copy) NSString * _Nullable token;

@property (copy) NSString * _Nullable interAppAddressCallback;

@end
