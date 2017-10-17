#import <JSONModel/JSONModel.h>

@interface TradeItTransactionHistory : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional>  * date;

@property (nonatomic, copy, nullable) NSString<Optional>  * description;

@property (nonatomic, copy, nullable) NSNumber<Optional>  * price;

@property (nonatomic, copy, nullable) NSString<Optional>  * symbol;

@property (nonatomic, copy, nullable) NSNumber<Optional>  * commission;

@property (nonatomic, copy, nullable) NSNumber<Optional>  * amount;

@property (nonatomic, copy, nullable) NSString<Optional>  * action;

@property (nonatomic, copy, nullable) NSString<Optional>  * type;

@property (nonatomic, copy, nullable) NSString<Optional>  * id;

@property (nonatomic, copy, nullable) NSNumber<Optional>  * quantity;

@end
