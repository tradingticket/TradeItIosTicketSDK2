#import <Foundation/Foundation.h>
#import "TradeItAuthLinkResult.h"

@interface TradeItLinkedLogin : NSObject

@property (nonnull) NSString *label;
@property (nonnull) NSString *broker;
@property (nonnull) NSString *userId;
@property (nonnull) NSString *keychainId;

- (nonnull id)initWithLabel:(NSString * _Nonnull)label
                     broker:(NSString * _Nonnull)broker
                     userId:(NSString * _Nonnull)userId
              keyChainId:(NSString * _Nonnull)keychainId;

@end
