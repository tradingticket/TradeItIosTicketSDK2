#import <Foundation/Foundation.h>
#import "TradeItJsonConverter.h"
#import "TradeItErrorResult.h"

@implementation TradeItJsonConverter

+ (NSURL *)getEmsBaseUrlForEnvironment:(TradeitEmsEnvironments)env {
    TradeItEmsApiVersion version = TradeItEmsApiVersion_2;

    return [TradeItJsonConverter getEmsBaseUrlForEnvironment:env
                                                     version:version];
}

+ (NSURL *)getEmsBaseUrlForEnvironment:(TradeitEmsEnvironments)env
                               version:(TradeItEmsApiVersion)version {
    NSString *baseUrl = [TradeItJsonConverter getEmsHostForEnvironment:env];
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

+ (NSString *)getEmsHostForEnvironment:(TradeitEmsEnvironments)env {
    switch (env) {
        case TradeItEmsProductionEnv:
            return @"https://ems.tradingticket.com/";
        case TradeItEmsTestEnv:
            return @"https://ems.qa.tradingticket.com/";
        case TradeItEmsLocalEnv:
            return @"http://localhost:8080/";
        default:
            NSLog(@"Invalid environment %d - directing to production by default", env);
            return @"https://ems.tradingticket.com/";
    }
}

+ (NSMutableURLRequest *)buildJsonRequestForModel:(JSONModel *)requestObject
                                        emsAction:(NSString *)emsAction
                                      environment:(TradeitEmsEnvironments)env {
    NSData *requestData = [[requestObject toJSONString] dataUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:emsAction
                        relativeToURL:[TradeItJsonConverter getEmsBaseUrlForEnvironment:env]];

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
