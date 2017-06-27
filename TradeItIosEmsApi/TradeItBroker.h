#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TradeItBrokerInstrument.h"

@protocol TradeItBroker
@end

@interface TradeItBroker : JSONModel

@property (nullable, nonatomic) NSString *shortName;
@property (nullable, nonatomic) NSString *longName;
@property (nullable, copy) NSArray<TradeItBrokerInstrument> *brokerInstruments;
@property (nullable, nonatomic) NSString <Ignore> *brokerShortName;
@property (nullable, nonatomic) NSString <Ignore> *brokerLongName;

@end
