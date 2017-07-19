#import <Foundation/Foundation.h>
#import "TradeItAuthLinkResult.h"

@interface TradeItLinkedLogin : NSObject

@property (nullable) NSString *label;
@property (nullable) NSString *broker;
@property (nullable) NSString *userId;
@property (nullable) NSString *keychainId;

- (nonnull id)initWithLabel:(NSString * _Nonnull)label
                     broker:(NSString * _Nonnull)broker
                     userId:(NSString * _Nonnull)userId
              keyChainId:(NSString * _Nonnull)keychainId;

@end
