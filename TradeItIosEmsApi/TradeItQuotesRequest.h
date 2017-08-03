//
//  TradeItQuotesRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItQuotesRequest : TradeItRequest

@property (copy) NSString * _Nullable symbol;
@property (copy) NSString * _Nullable broker;
@property (copy) NSString * _Nullable symbols;
@property (copy) NSString * _Nullable apiKey;
@property (copy) NSString * _Nullable suffixMarket;

- (id _Nonnull)initWithSymbol:(NSString * _Nonnull) symbol
                    andApiKey: (NSString * _Nonnull) apiKey;

- (id _Nonnull)initWithFxSymbol:(NSString * _Nonnull) symbol
                      andBroker: (NSString * _Nonnull) broker
                      andApiKey: (NSString * _Nonnull) apiKey;

- (id _Nonnull)initWithSymbols:(NSArray * _Nonnull) symbols
                     andApiKey: (NSString * _Nonnull) apiKey;

- (id _Nonnull)initWithSymbol:(NSString * _Nonnull) symbol
              andMarketSuffix: (NSString * _Nonnull) suffix
                    andApiKey: (NSString * _Nonnull) apiKey;

@end
