#import "TradeItRequest.h"

@interface TradeItAuthenticatedRequest: TradeItRequest
@property (nonatomic, copy) NSString *token;
@end
