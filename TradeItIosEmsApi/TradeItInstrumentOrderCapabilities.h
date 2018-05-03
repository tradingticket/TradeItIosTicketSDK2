#import <JSONModel/JSONModel.h>
#import "TradeItInstrumentCapability.h"
#import "TradeItInstrumentActionCapability.h"

@protocol TradeItInstrumentOrderCapabilities

@end

@interface TradeItInstrumentOrderCapabilities : JSONModel

@property (nonatomic, copy) NSString * _Nonnull instrument;
@property (nonatomic, copy) NSString<Optional> * _Nullable tradeItSymbol;
@property (nonatomic, copy) NSNumber<Optional> * _Nullable precision;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentActionCapability> * _Nullable actions;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable expirationTypes;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable priceTypes;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable orderTypes;
@property (nonatomic) BOOL symbolSpecific;

@end
