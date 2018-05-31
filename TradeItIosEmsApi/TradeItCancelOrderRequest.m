#import "TradeItCancelOrderRequest.h"

@implementation TradeItCancelOrderRequest
    - (id)initWithInterAppAddressCallback:(NSString *)interAppAddressCallback {
        self = [super init];

        if (self) {
            self.interAppAddressCallback = interAppAddressCallback;
        }

        return self;
    }
@end
