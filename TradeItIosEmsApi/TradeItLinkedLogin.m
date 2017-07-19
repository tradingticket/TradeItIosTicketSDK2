#import "TradeItLinkedLogin.h"

@implementation TradeItLinkedLogin

- (id)initWithLabel:(NSString *)label
             broker:(NSString *)broker
             userId:(NSString *)userId
         keyChainId:(NSString *)keychainId {
    self = [super init];
    if (self) {
        self.label = label;
        self.broker = broker;
        self.userId = userId;
        self.keychainId = keychainId;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Label: %@, Broker: %@, UserId: %@, KeychainId: %@", self.label, self.broker, self.userId, self.keychainId];
}

@end
