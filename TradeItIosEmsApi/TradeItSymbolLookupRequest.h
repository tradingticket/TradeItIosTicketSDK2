//
//  TradeItSymbolLookupRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItSymbolLookupRequest : TradeItRequest

@property (copy) NSString * query;

-(id) initWithQuery:(NSString *) query;

// Session Token - Will be set by the session associated with the request
// Setting this here will be overriden
@property (copy) NSString * token;

@end
