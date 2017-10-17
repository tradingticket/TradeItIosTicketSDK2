#import "TradeItResult.h"

@class TradeItTransaction;

@protocol TradeItTransaction

@end

@interface TradeItTransactionsHistoryResult : TradeItResult

@property(nonatomic, copy, nullable) NSArray<TradeItTransaction*> <Optional, TradeItTransaction>  * transactionHistoryDetailsList;

@end
