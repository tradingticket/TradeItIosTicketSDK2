#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2.h>

@interface TradeItCryptoQuotesResult : TradeItResult

@property (nonatomic, copy) NSNumber<Optional> * _Nonnull ask;
@property (nonatomic, copy) NSNumber<Optional> * _Nonnull bid;
@property (nonatomic, copy) NSNumber<Optional> * _Nonnull open;
@property (nonatomic, copy) NSNumber<Optional> * _Nonnull last;
@property (nonatomic, copy) NSNumber<Optional> * _Nonnull volume;
@property (nonatomic, copy) NSNumber<Optional> * _Nonnull dayLow;
@property (nonatomic, copy) NSNumber<Optional> * _Nonnull dayHigh;

@end
