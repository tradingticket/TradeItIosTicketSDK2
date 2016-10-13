//
//  TradeItQuote.m
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 2/17/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItQuote.h"

@implementation TradeItQuote

-(id)initWithQuoteData:(NSDictionary *)quoteData {
    if (self = [super init]) {
        self.symbol = [quoteData valueForKey: @"symbol"];
        self.companyName = [quoteData valueForKey: @"companyName"];
        self.askPrice = [quoteData valueForKey: @"askPrice"];
        self.bidPrice = [quoteData valueForKey: @"bidPrice"];
        self.change = [quoteData valueForKey: @"change"];
        self.pctChange = [quoteData valueForKey: @"pctChange"];
        self.lastPrice = [quoteData valueForKey: @"lastPrice"];
        self.low = [quoteData valueForKey: @"low"];
        self.high = [quoteData valueForKey: @"high"];
        self.volume = [quoteData valueForKey: @"volume"];
    }

    return self;
}

@end
