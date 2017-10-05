#import <JSONModel/JSONModel.h>

@protocol TradeItPreviewMessageLink

@end

@interface TradeItPreviewMessageLink : JSONModel

@property (nonatomic, copy, nonnull) NSString *label;
@property (nonatomic, copy, nonnull) NSString *url;

@end
