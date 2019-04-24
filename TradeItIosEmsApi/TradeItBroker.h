#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TradeItBrokerInstrument.h"
#import "TradeItBrokerLogo.h"

@protocol TradeItBroker
@end

@interface TradeItBroker : JSONModel

@property (nullable, nonatomic) NSString *shortName;
@property (nullable, nonatomic) NSString *longName;
@property (nullable, copy) NSArray<TradeItBrokerInstrument> *brokerInstruments;
@property (nullable, nonatomic) NSString <Ignore> *brokerShortName;
@property (nullable, nonatomic) NSString <Ignore> *brokerLongName;
@property (nullable, nonatomic) NSArray<TradeItBrokerLogo> *logos;

@end
