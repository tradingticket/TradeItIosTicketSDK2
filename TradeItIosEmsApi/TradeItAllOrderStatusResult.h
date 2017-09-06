#import "TradeItResult.h"
#import "TradeItOrderStatusDetails.h"

@interface TradeItAllOrderStatusResult : TradeItResult

@property (nonatomic, copy, nullable) NSArray<TradeItOrderStatusDetails*> <Optional, TradeItOrderStatusDetails>  * orderStatusDetailsList;

@end
