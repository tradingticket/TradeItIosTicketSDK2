//
//  TradeItSymbolLookupRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItSymbolLookupRequest : TradeItRequest

@property (copy, nonnull) NSString * query;

-(_Nonnull id) initWithQuery:(NSString * _Nonnull) query;

// Session Token - Will be set by the session associated with the request
// Setting this here will be overriden
@property (copy, nullable) NSString * token;

@end
