#import <JSONModel/JSONModel.h>
#import "CachedLinkedBroker.h"
#import "CachedLinkedBrokerAccount.h"

@interface CachedLinkedBroker : JSONModel

@property (nonatomic) NSArray<CachedLinkedBrokerAccount*> <CachedLinkedBrokerAccount> *accounts;

@property (nonatomic) NSDate<Optional> *accountsLastUpdated;

@property (nonatomic) BOOL isAccountLinkDelayedError;

@end
