#import "TradeItComplete1FARequest.h"

@implementation TradeItComplete1FARequest

-(id) initWithToken:(NSString*) token {
    self = [super init];
    if(self){
        self.token = token;
    }
    return self;
}

@end
