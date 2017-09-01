#import <JSONModel/JSONModel.h>

@protocol TradeItOrderFill

@end

@interface TradeItOrderFill : JSONModel

@property (nonatomic, copy) NSString<Optional> * _Nullable timestamp;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable price;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable quantity;

@end
