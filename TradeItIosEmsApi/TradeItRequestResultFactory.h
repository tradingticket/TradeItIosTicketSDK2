#import "TradeItTypeDefs.h"
#import "TradeItResult.h"

@interface TradeItRequestResultFactory : NSObject

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
