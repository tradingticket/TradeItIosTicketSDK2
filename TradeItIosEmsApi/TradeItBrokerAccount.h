#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TradeItInstrumentOrderCapabilities.h"

@protocol TradeItBrokerAccount
@end

@interface TradeItBrokerAccount :  JSONModel<NSCopying>

@property (nonatomic, nonnull) NSString *accountBaseCurrency;
@property (nonatomic, nonnull) NSString *accountNumber;
@property (nonatomic, nonnull) NSString *accountIndex;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic) BOOL tradable;
@property (nonatomic) BOOL userCanDisableMargin;

@property (nonatomic, copy, nonnull) NSArray<TradeItInstrumentOrderCapabilities> *orderCapabilities;

- (id _Nonnull)initWithAccountBaseCurrency:(NSString *_Nonnull)accountBaseCurrency
                    accountNumber:(NSString *_Nonnull)accountNumber
                             name:(NSString *_Nonnull)name
                         tradable:(BOOL)tradable;

@end
