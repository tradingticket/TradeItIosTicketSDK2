#import "TradeItGetProxyVoteUrlRequest.h"

@implementation TradeItGetProxyVoteUrlRequest
-(id) initWithAccountNumber:(NSString *) accountNumber
                     symbol:(NSString *) symbol {
    self = [super init];
    if(self) {
        self.accountNumber = accountNumber;
        self.symbol = symbol;
    }
    return self;
}
@end
