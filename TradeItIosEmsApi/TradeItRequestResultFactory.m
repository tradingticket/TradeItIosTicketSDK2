#import <Foundation/Foundation.h>
#import "TradeItRequestResultFactory.h"
#import "TradeItErrorResult.h"
#import "TradeItParseErrorResult.h"
#import "TradeItUserAgentProvider.h"

@implementation TradeItRequestResultFactory

static id<RequestFactory> _requestFactory = nil;

+ (id<RequestFactory> _Nullable)requestFactory { return _requestFactory; }
+ (void)setRequestFactory:(id<RequestFactory> _Nullable)requestFactory { _requestFactory = requestFactory; }

+ (NSURL *)getBaseUrlForEnvironment:(TradeitEmsEnvironments)env {
    TradeItEmsApiVersion version = TradeItEmsApiVersion_2;

    return [TradeItRequestResultFactory getBaseUrlForEnvironment:env
                                                         version:version];
}

+ (NSURL *)getBaseUrlForEnvironment:(TradeitEmsEnvironments)env
                            version:(TradeItEmsApiVersion)version {
    NSString *baseUrl = [TradeItRequestResultFactory getHostForEnvironment:env];
    NSString *versionPath = [TradeItRequestResultFactory getApiPrefixForVersion:version];

    baseUrl = [baseUrl stringByAppendingString:versionPath];

    return [NSURL URLWithString:baseUrl];
}

+ (NSString *)getApiPrefixForVersion:(TradeItEmsApiVersion)version {
    switch (version) {
        case TradeItEmsApiVersion_1:
            return @"api/v1/";
        case TradeItEmsApiVersion_2:
            return @"api/v2/";
        default:
            NSLog(@"Invalid version %d - directing to v2 by default", version);
            return @"api/v2/";
    }
}

+ (void)setHost:(NSString *)host
 ForEnvironment:(TradeitEmsEnvironments)env {
    [self getEnvToHostDict][@(env)] = host;
}

+ (NSMutableDictionary<NSNumber *, NSString *> *)getEnvToHostDict {
    static NSMutableDictionary<NSNumber *, NSString *> *envToHostDict = nil;

    static dispatch_once_t onceToken;
    dispatch_once(
        &onceToken,
        ^{
            envToHostDict = [@{
                 @(TradeItEmsProductionEnv): @"https://ems.tradingticket.com/",
                 @(TradeItEmsTestEnv): @"https://ems.qa.tradingticket.com/",
                 @(TradeItEmsLocalEnv): @"https://localhost:8443/"
            } mutableCopy];
        }
    );

    return envToHostDict;
}

+ (NSString *)getHostForEnvironment:(TradeitEmsEnvironments)env {
    if ([self getEnvToHostDict][@(env)]) {
        return [self getEnvToHostDict][@(env)];
    } else {
        NSLog(@"Invalid environment [%d] - directing to TradeIt production by default", env);
        return @"https://ems.tradingticket.com/";
    }
}

+ (NSURLRequest *)buildJsonRequestForModel:(JSONModel *)requestObject
                                        emsAction:(NSString *)emsAction
                                      environment:(TradeitEmsEnvironments)env {
    NSString *userAgent = [TradeItUserAgentProvider getUserAgent];

    NSString *requestJsonString = [requestObject toJSONString];

    NSURL *url = [NSURL URLWithString:emsAction
                        relativeToURL:[TradeItRequestResultFactory getBaseUrlForEnvironment:env]];

    NSDictionary *headers = @{
                              @"Accept": @"application/json",
                              @"Content-Type": @"application/json",
                              @"User-Agent": userAgent
                              };

    NSURLRequest *request = [TradeItRequestResultFactory.requestFactory buildPostRequestForUrl:url
                                                                                  jsonPostBody:requestJsonString
                                                                                       headers:headers];

    return request;
}

+ (TradeItResult *)buildResult:(TradeItResult *)tradeItResult
                    jsonString:(NSString *)jsonString {
    JSONModelError *jsonModelError = nil;
    TradeItResult *resultFromJson = [tradeItResult initWithString:jsonString error:&jsonModelError];

    if (jsonModelError != nil) {
        NSLog(@"Response did not match expected JSONModel class=%@ from ems server error=%@ response=%@", [tradeItResult class], jsonModelError, jsonString);
        return [TradeItParseErrorResult errorWithSystemMessage:@"Error parsing json response."];
    }

    return resultFromJson;
}

@end
