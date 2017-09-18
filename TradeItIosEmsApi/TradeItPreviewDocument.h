#import <JSONModel/JSONModel.h>

@protocol TradeItPreviewDocument

@end

@interface TradeItPreviewDocument : JSONModel

@property (nonatomic, copy, nonnull) NSString *label;
@property (nonatomic, copy, nonnull) NSString *url;

@end
