#import <JSONModel/JSONModel.h>
#import "TradeItAccountOverview.h"
#import "TradeItFxAccountOverview.h"

@protocol CachedLinkedBrokerAccount
@end

@interface CachedLinkedBrokerAccount : JSONModel

@property (nonatomic) NSString *accountName;

@property (nonatomic) NSString *accountNumber;

@property (nonatomic) NSString *accountIndex;

@property (nonatomic) NSString *accountBaseCurrency;

@property (nonatomic) NSDate<Optional> *balanceLastUpdated;

@property (nonatomic) TradeItAccountOverview<Optional> *balance;

@property (nonatomic) TradeItFxAccountOverview<Optional> *fxBalance;

@property (nonatomic) BOOL isEnabled;

@end
