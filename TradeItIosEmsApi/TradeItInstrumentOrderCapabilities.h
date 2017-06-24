#import <JSONModel/JSONModel.h>
#import "TradeItInstrumentCapability.h"

@protocol TradeItInstrumentOrderCapabilities

@end

@interface TradeItInstrumentOrderCapabilities : JSONModel

@property (nonatomic, copy) NSString * _Nonnull instrument;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable actions;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable expirationTypes;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable priceTypes;
@property (nonatomic, copy) NSArray<Optional, TradeItInstrumentCapability> * _Nullable orderTypes;

@end
