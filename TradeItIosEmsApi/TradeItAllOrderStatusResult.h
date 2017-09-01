#import "TradeItResult.h"
#import "TradeItOrderStatusDetails.h"

@interface TradeItAllOrderStatusResult : TradeItResult

@property (nonatomic, copy) NSArray<TradeItOrderStatusDetails*> <Optional, TradeItOrderStatusDetails>  * _Nullable orderStatusDetailsList;

@end
