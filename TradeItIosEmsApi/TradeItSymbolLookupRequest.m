#import "TradeItSymbolLookupRequest.h"

@implementation TradeItSymbolLookupRequest

-(id) initWithQuery:(NSString *) query {
    self = [super init];
    if(self) {
        self.query = query;
    }
    return self;
}

@end
