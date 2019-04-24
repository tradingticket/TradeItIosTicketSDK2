//
//  TradeItSymbolLookupRequest.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItSymbolLookupRequest.h"

@implementation TradeItSymbolLookupRequest

-(id) initWithQuery:(NSString *) query {
    self = [super init];
    if(self) {
        self.query = query;
    }
    return self;
}

@end
