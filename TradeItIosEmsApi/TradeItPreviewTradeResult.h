#import "TradeItResult.h"
#import "TradeItPreviewTradeOrderDetails.h"
#import "TradeItPreviewMessage.h"

@interface TradeItPreviewTradeResult : TradeItResult

/**
 *  An array containing all the warnings returned by the broker
 */
@property (nonatomic, nullable, copy) NSArray<Optional> *warningsList;

/**
 *  An array containing all the warnings that need to be acknowledged by the user. Should be displayed to the user with a checkbox asking him to review and acknowledge the following warnings before placing the order.
 */
@property (nonatomic, nullable, copy) NSArray<Optional> *ackWarningsList;

@property (nonatomic, nullable, copy) NSArray<TradeItPreviewMessage *> <Optional, TradeItPreviewMessage> * messages;

/**
 *  A TradeIt internal orderId used to reference the preview order, needed to place the order
 */
@property (nonatomic, nonnull, copy) NSString *orderId;

/**
 *  An Object with order details. @see TradeItStockOrEtfTradeReviewOrderDetails
 */
@property (nonatomic, nullable, copy) TradeItPreviewTradeOrderDetails *orderDetails;

// The base currency used for the positions
@property (nonatomic, nullable, copy) NSString<Optional> *accountBaseCurrency;

@end
