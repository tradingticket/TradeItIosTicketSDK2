#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol TradeItBrokerInstrument
@end

@interface TradeItBrokerInstrument : JSONModel

@property (nonatomic) NSString *instrument;
@property (nonatomic) BOOL isFeatured;
@property (nonatomic) BOOL supportsAccountOverview;
@property (nonatomic) BOOL supportsFxRates;
@property (nonatomic) BOOL supportsOrderCanceling;
@property (nonatomic) BOOL supportsOrderStatus;
@property (nonatomic) BOOL supportsPositions;
@property (nonatomic) BOOL supportsTrading;
@property (nonatomic) BOOL supportsTransactionHistory;

@end
