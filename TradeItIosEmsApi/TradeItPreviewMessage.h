#import <JSONModel/JSONModel.h>
#import "TradeItPreviewMessageLink.h"

@protocol TradeItPreviewMessage

@end

@interface TradeItPreviewMessage : JSONModel

@property (nonatomic, nullable, copy) NSString<Optional> *message;
@property (nonatomic) BOOL requiresAcknowledgement;
@property (nonatomic, nonnull, copy) NSArray<TradeItPreviewMessageLink *> <Optional, TradeItPreviewMessageLink> *links;

@end
