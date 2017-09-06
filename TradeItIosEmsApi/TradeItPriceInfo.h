#import <JSONModel/JSONModel.h>

@interface TradeItPriceInfo : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional> * type;

@property (nonatomic, copy, nullable) NSNumber<Optional> * limitPrice;

@property (nonatomic, copy, nullable) NSNumber<Optional> * stopPrice;

@property (nonatomic, copy, nullable) NSNumber<Optional> * trailPrice;

@end
