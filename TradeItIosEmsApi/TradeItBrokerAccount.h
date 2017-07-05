#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TradeItInstrumentOrderCapabilities.h"

@protocol TradeItBrokerAccount
@end

@interface TradeItBrokerAccount :  JSONModel<NSCopying>

@property (nonatomic) NSString *accountBaseCurrency;
@property (nonatomic) NSString *accountNumber;
@property (nonatomic) NSString *accountIndex;
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL tradable;

@property (nonatomic, copy) NSArray<TradeItInstrumentOrderCapabilities> *orderCapabilities;

- (id)initWithAccountBaseCurrency:(NSString *)accountBaseCurrency
                    accountNumber:(NSString *)accountNumber
                             name:(NSString *)name
                         tradable:(BOOL)tradable;

@end
