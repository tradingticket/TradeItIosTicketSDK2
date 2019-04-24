#import <JSONModel/JSONModel.h>

@protocol TradeItInstrumentCapability

@end

@interface TradeItInstrumentCapability : JSONModel

@property (nonatomic, copy) NSString * _Nonnull displayLabel;
@property (nonatomic, copy) NSString * _Nonnull value;
@property (nonatomic, copy, nullable) NSArray<NSString *> <Optional> *supportedOrderQuantityTypes;

@end
