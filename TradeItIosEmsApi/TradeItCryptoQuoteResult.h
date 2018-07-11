#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2.h>

@interface TradeItCryptoQuoteResult : TradeItResult

@property (nonatomic, copy, nullable) NSNumber<Optional> * ask;
@property (nonatomic, copy, nullable) NSNumber<Optional> * bid;
@property (nonatomic, copy, nullable) NSNumber<Optional> * open;
@property (nonatomic, copy, nullable) NSNumber<Optional> * last;
@property (nonatomic, copy, nullable) NSNumber<Optional> * volume;
@property (nonatomic, copy, nullable) NSNumber<Optional> * dayLow;
@property (nonatomic, copy, nullable) NSNumber<Optional> * dayHigh;
@property (nonatomic, copy, nullable) NSString<Optional> * dateTime;

@end
