//
//  TradeItQuotesRequest.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItQuotesRequest.h"

@implementation TradeItQuotesRequest

-(id) initWithSymbol:(NSString *) symbol
           andApiKey:(NSString *) apiKey {
    self = [super init];
    if(self) {
        self.symbol = symbol;
        self.apiKey = apiKey;
    }
    
    if([symbol containsString:@".SI"]) {
        self.symbol = [symbol substringToIndex:[symbol rangeOfString:@".SI"].location];
        self.suffixMarket = @"SI";
    }
    
    return self;
}

-(id) initWithFxSymbol:(NSString *) symbol
             andBroker:(NSString *)broker
             andApiKey:(NSString *) apiKey {
    self = [self initWithSymbol:symbol andApiKey:apiKey];
    self.broker = broker;
    return self;
}

-(id) initWithSymbols:(NSArray *) symbols
            andApiKey:(NSString *) apiKey {
    self = [super init];
    if(self) {
        self.symbols = [symbols componentsJoinedByString:@","];
        self.apiKey = apiKey;
    }
    return self;
}

-(id) initWithSymbol:(NSString *) symbol
     andMarketSuffix: (NSString *) suffix
           andApiKey:(NSString *) apiKey {
    self = [super init];
    if(self) {
        self.symbol = symbol;
        self.suffixMarket = suffix;
        self.apiKey = apiKey;
    }
    return self;
}

@end
