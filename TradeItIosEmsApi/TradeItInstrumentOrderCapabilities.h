#import <JSONModel/JSONModel.h>
#import "TradeItInstrumentCapability.h"

@protocol TradeItInstrumentOrderCapabilities

@end

@interface TradeItInstrumentOrderCapabilities : JSONModel

@property (nonatomic, copy) NSString * _Nonnull instrument;
@property (nonatomic, copy) NSString<Optional> * _Nullable tradeItSymbol;
@property (nonatomic, copy) NSNumber<Optional> * _Nullable precision;
@property (nonatomic, copy, nonnull) NSArray<TradeItInstrumentCapability *> <TradeItInstrumentCapability> *actions;
@property (nonatomic, copy, nonnull) NSArray<TradeItInstrumentCapability *> <TradeItInstrumentCapability> *expirationTypes;
@property (nonatomic, copy, nonnull) NSArray<TradeItInstrumentCapability *> <TradeItInstrumentCapability> *priceTypes;
@property (nonatomic) BOOL symbolSpecific;

@end
