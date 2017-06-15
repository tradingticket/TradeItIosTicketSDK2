#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface TradeItBrokerServices : JSONModel

@property (nonatomic) BOOL cancelTradeService;
@property (nonatomic) BOOL stockOrEtfOrderTradeService;
@property (nonatomic) BOOL optionTradeService;
@property (nonatomic) BOOL transactionService;
@property (nonatomic) BOOL positionService;
@property (nonatomic) BOOL balanceService;
@property (nonatomic) BOOL fxTradeService;


//{"cancelTradeService":true,"stockOrEtfOrderTradeService":true,"optionTradeService":false,"transactionService":true,"positionService":true,"balanceService":true,"fxTradeService":false}
@end
