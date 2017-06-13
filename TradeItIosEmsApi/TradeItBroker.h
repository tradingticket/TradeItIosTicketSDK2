#import <Foundation/Foundation.h>
#import "TradeItBrokerServices.h"

@interface TradeItBroker : NSObject

@property (nullable, nonatomic, copy) NSString *brokerShortName;

@property (nullable, nonatomic, copy) NSString *brokerLongName;

@property (nonatomic) BOOL featured;

@property (nullable, nonatomic, copy) TradeItBrokerServices *services;

- (nonnull id)initWithShortName:(NSString * _Nullable)brokerShortName
                       longName:(NSString * _Nullable)brokerLongName;

@end
