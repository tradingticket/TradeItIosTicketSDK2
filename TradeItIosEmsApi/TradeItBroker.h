#import <Foundation/Foundation.h>
#import "TradeItBrokerServices.h"
#import <JSONModel/JSONModel.h>

@interface TradeItBroker : JSONModel

@property (nullable, nonatomic, copy) NSString *brokerShortName;

@property (nullable, nonatomic, copy) NSString *brokerLongName;

@property (nonatomic) BOOL featured;

@property (nullable, nonatomic, copy) TradeItBrokerServices *services;

- (nonnull id)initWithShortName:(NSString * _Nullable)brokerShortName
                       longName:(NSString * _Nullable)brokerLongName;

@end
