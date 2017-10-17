#import "TradeItResult.h"

@class TradeItTransactionHistory;

@protocol TradeItTransactionHistory

@end

@interface TradeItTransactionsHistoryResult : TradeItResult

@property(nonatomic, copy, nullable) NSArray<TradeItTransactionHistory*> <Optional, TradeItTransactionHistory>  * transactionHistoryDetailsList;

@end
