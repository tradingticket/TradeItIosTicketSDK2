#import "TradeItTypeDefs.h"
#import "TradeItResult.h"

@protocol RequestFactory
// TODO: Can this be Nonnull return?
- (NSURLRequest * _Nonnull)buildPostRequestForUrl:(NSURL * _Nonnull)url
                                      jsonPostBody:(NSString * _Nonnull)parameters
                                           headers:(NSDictionary<NSString *, NSString *> * _Nonnull)headers;
@end


@interface TradeItRequestResultFactory : NSObject

@property (class) id<RequestFactory> _Nullable requestFactory;

+ (NSURLRequest * _Nonnull)buildJsonRequestForModel:(JSONModel *)requestObject
                                        emsAction:(NSString *)action
                                      environment:(TradeitEmsEnvironments)env;


+ (TradeItResult *)buildResult:(TradeItResult *)tradeItResult
                    jsonString:(NSString *)jsonString;

+ (NSURL *)getBaseUrlForEnvironment:(TradeitEmsEnvironments)env;

+ (NSString *)getHostForEnvironment:(TradeitEmsEnvironments)env;

+ (void)setHost:(NSString *)host
 ForEnvironment:(TradeitEmsEnvironments)env;

@end
