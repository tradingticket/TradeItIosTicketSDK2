#import "TradeItResult.h"

@interface TradeItAuthLinkResult : TradeItResult

@property (nonatomic, copy) NSString * _Nonnull userId;
@property (nonatomic, copy) NSString * _Nonnull userToken;

- (NSString * _Nonnull)description;

@end
