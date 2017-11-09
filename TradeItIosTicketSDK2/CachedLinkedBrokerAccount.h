#import <JSONModel/JSONModel.h>
#import "TradeItAccountOverview.h"
#import "TradeItFxAccountOverview.h"

@protocol CachedLinkedBrokerAccount
@end

@interface CachedLinkedBrokerAccount : JSONModel

@property (nonatomic, nonnull) NSString *accountName;

@property (nonatomic, nonnull) NSString *accountNumber;

@property (nonatomic, nonnull) NSString *accountIndex;

@property (nonatomic, nonnull) NSString *accountBaseCurrency;

@property (nonatomic, nullable) NSString<Optional> *marginType;

@property (nonatomic, nullable) NSDate<Optional> *balanceLastUpdated;

@property (nonatomic, nullable) TradeItAccountOverview<Optional> *balance;

@property (nonatomic, nullable) TradeItFxAccountOverview<Optional> *fxBalance;

@property (nonatomic) BOOL isEnabled;

@end
