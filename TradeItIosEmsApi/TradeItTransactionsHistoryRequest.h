#import "TradeItRequest.h"

@interface TradeItTransactionsHistoryRequest : TradeItRequest

    @property (nonatomic, copy, nullable) NSString * token;
    @property (nonatomic, copy, nullable) NSString * accountNumber;

@end
