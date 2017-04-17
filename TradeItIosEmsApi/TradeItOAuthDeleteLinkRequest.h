#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2.h>

@interface TradeItOAuthDeleteLinkRequest : TradeItRequest

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userToken;

@end
