#import "TradeItResult.h"
#import "TradeItSymbol.h"

@interface TradeItSymbolLookupResult : TradeItResult

// The query you passed in
@property (nullable, copy) NSString<Optional> *query;

// List of matches
@property (nullable, copy) NSArray<Optional, TradeItSymbol> *results;

@end
