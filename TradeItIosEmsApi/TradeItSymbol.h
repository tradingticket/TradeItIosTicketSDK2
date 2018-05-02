#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol TradeItSymbol
@end

@interface TradeItSymbol : JSONModel<NSCopying>

// The company street symbol
@property (nullable, copy) NSString<Optional> *symbol;

// The company name
@property (nullable, copy) NSString<Optional> *name;

@end
