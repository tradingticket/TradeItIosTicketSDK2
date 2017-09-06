#import <JSONModel/JSONModel.h>

@protocol TradeItOrderFill

@end

@interface TradeItOrderFill : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional> * timestamp;

@property (nonatomic, copy, nullable) NSNumber<Optional> * price;

@property (nonatomic, copy, nullable) NSNumber<Optional> * quantity;

@end
