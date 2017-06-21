#import "TradeItBrokerServices.h"

@implementation TradeItBrokerServices

- (NSString *)description {
    return [NSString stringWithFormat: @"[TradeItBrokerServices: cancelTradeService=%@ stockOrEtfOrderTradeService=%@ optionTradeService=%@ transactionService=%@ positionService=%@ balanceService=%@ fxTradeService=%@]",
            self.cancelTradeService ? @"true" : @"false",
            self.stockOrEtfOrderTradeService ? @"true" : @"false",
            self.optionTradeService ? @"true" : @"false",
            self.transactionService ? @"true" : @"false",
            self.positionService ? @"true" : @"false",
            self.balanceService ? @"true" : @"false",
            self.fxTradeService ? @"true" : @"false"];
}

@end
