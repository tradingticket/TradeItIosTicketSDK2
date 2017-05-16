#import <Foundation/Foundation.h>
#import "TradeItJsonConverter.h"
#import "TradeItErrorResult.h"

@implementation TradeItJsonConverter

+ (NSURL *)getBaseUrlForEnvironment:(TradeitEmsEnvironments)env {
    TradeItEmsApiVersion version = TradeItEmsApiVersion_2;

    return [TradeItJsonConverter getBaseUrlForEnvironment:env
                                                  version:version];
}

+ (NSURL *)getBaseUrlForEnvironment:(TradeitEmsEnvironments)env
                            version:(TradeItEmsApiVersion)version {
    NSString *baseUrl = [TradeItJsonConverter getHostForEnvironment:env];
    NSString *versionPath = [TradeItJsonConverter getApiPrefixForVersion:version];

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
                 @(TradeItEmsLocalEnv): @"http://localhost:8080/"
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

+ (NSMutableURLRequest *)buildJsonRequestForModel:(JSONModel *)requestObject
                                        emsAction:(NSString *)emsAction
                                      environment:(TradeitEmsEnvironments)env {
    NSData *requestData = [[requestObject toJSONString] dataUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:emsAction
                        relativeToURL:[TradeItJsonConverter getBaseUrlForEnvironment:env]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];

    return request;
}

+ (TradeItResult *)buildResult:(TradeItResult *)tradeItResult
                    jsonString:(NSString *)jsonString {
    JSONModelError *jsonModelError = nil;
    TradeItResult *resultFromJson = [tradeItResult initWithString:jsonString error:&jsonModelError];

    if (jsonModelError != nil)
    {
        NSLog(@"Received invalid json from ems server error=%@ response=%@", jsonModelError, jsonString);
        return [TradeItErrorResult errorWithSystemMessage:@"error parsing json response"];
    }

    return resultFromJson;
}

@end
