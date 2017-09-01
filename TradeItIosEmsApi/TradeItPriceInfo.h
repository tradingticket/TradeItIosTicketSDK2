#import <JSONModel/JSONModel.h>

@interface TradeItPriceInfo : JSONModel

@property (nonatomic, copy) NSString<Optional> * _Nullable type;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable limitPrice;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable stopPrice;

@property (nonatomic, copy) NSNumber<Optional> * _Nullable trailPrice;

@end
