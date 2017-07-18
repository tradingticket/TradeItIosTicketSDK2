#import "TradeItTypeDefs.h"
#import "TradeItResult.h"

@protocol RequestFactory
- (NSURLRequest * _Nullable)buildRequestForUrl:(NSURL * _Nonnull)url
                                    httpMethod:(NSString * _Nonnull)httpMethod
                                    parameters:(NSDictionary<NSString *, NSString *> * _Nonnull)parameters
                                       headers:(NSDictionary<NSString *, NSString *> * _Nonnull)headers;
@end


@interface TradeItRequestResultFactory : NSObject

@property (class) id<RequestFactory> _Nullable requestFactory;

+ (NSMutableURLRequest *)buildJsonRequestForModel:(JSONModel *)requestObject
                                        emsAction:(NSString *)action
                                      environment:(TradeitEmsEnvironments)env;


+ (TradeItResult *)buildResult:(TradeItResult *)tradeItResult
                    jsonString:(NSString *)jsonString;

+ (NSURL *)getBaseUrlForEnvironment:(TradeitEmsEnvironments)env;

+ (NSString *)getHostForEnvironment:(TradeitEmsEnvironments)env;

+ (void)setHost:(NSString *)host
 ForEnvironment:(TradeitEmsEnvironments)env;

@end
