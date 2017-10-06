#import <JSONModel/JSONModel.h>

@protocol TradeItPreviewMessageLink

@end

@interface TradeItPreviewMessageLink : JSONModel

@property (nonatomic, copy, nullable) NSString<Optional> *label;
@property (nonatomic, copy, nonnull) NSString *url;

@end
