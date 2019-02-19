#import "TradeItRequest.h"

@interface TradeItGetProxyVoteUrlRequest : TradeItRequest

@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, copy, nonnull) NSString *accountNumber;
@property (nonatomic, copy, nonnull) NSString *symbol;

- (_Nonnull id)initWithAccountNumber:(NSString * _Nonnull)accountnumber
                       symbol:(NSString * _Nonnull)symbol;

@end
