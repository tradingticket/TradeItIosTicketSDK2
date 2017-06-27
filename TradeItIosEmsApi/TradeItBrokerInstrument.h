#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol TradeItBrokerInstrument
@end

@interface TradeItBrokerInstrument : JSONModel

@property (nonatomic) NSString *instrument;
@property (nonatomic) BOOL balance;
@property (nonatomic) BOOL cancel;
@property (nonatomic) BOOL isFeatured;
@property (nonatomic) BOOL orderStatus;
@property (nonatomic) BOOL positions;
@property (nonatomic) BOOL quote;
@property (nonatomic) BOOL trade;
@property (nonatomic) BOOL transactions;

@end
