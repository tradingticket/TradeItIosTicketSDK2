#import "TradeItLinkedLogin.h"

@implementation TradeItLinkedLogin

- (id)initWithLabel:(NSString *)label
             broker:(NSString *)broker
             brokerLongName:(NSString *)brokerLongName
             userId:(NSString *)userId
         keyChainId:(NSString *)keychainId {
    self = [super init];
    if (self) {
        self.label = label;
        self.broker = broker;
        self.brokerLongName = brokerLongName;
        self.userId = userId;
        self.keychainId = keychainId;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Label: %@, Broker: %@, Broker Long Name: %@, ,UserId: %@, KeychainId: %@", self.label, self.broker, self.brokerLongName, self.userId, self.keychainId];
}

@end
