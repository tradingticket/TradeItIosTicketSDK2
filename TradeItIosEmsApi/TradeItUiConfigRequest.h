#import <JSONModel/JSONModel.h>

@interface TradeItUiConfigRequest : JSONModel

@property (nonatomic, copy, nonnull) NSString *apiKey;

- (id _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey;

@end
