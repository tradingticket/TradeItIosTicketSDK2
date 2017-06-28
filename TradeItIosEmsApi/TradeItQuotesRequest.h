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

- (id _Nonnull)initWithSymbol:(NSString * _Nonnull) symbol;
- (id _Nonnull)initWithFxSymbol:(NSString * _Nonnull) symbol andBroker: (NSString * _Nonnull) broker;

- (id _Nonnull)initWithSymbols:(NSArray * _Nonnull) symbols;

- (id _Nonnull)initWithSymbol:(NSString * _Nonnull) symbol andMarketSuffix: (NSString * _Nonnull) suffix;

@end
