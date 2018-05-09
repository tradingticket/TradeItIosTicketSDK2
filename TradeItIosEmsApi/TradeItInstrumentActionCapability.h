#import "TradeItInstrumentCapability.h"

@protocol TradeItInstrumentActionCapability

@end

@interface TradeItInstrumentActionCapability : TradeItInstrumentCapability

@property (nonatomic, copy, nonnull) NSArray<NSString *> *supportedOrderQuantityTypes;

@end
