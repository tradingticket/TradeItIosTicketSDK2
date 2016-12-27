#import <Foundation/Foundation.h>
#import "TradeItJsonConverter.h"

#ifdef CARTHAGE
#import <TradeItIosTicketSDK2Carthage/TradeItIosTicketSDK2Carthage-Swift.h>
#else
#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2-Swift.h>
#endif

@implementation TradeItJsonConverter

+ (NSURL *)getEmsBaseUrlForEnvironment:(TradeitEmsEnvironments)env {
    TradeItEmsApiVersion version = TradeItEmsApiVersion_2;

    return [TradeItJsonConverter getEmsBaseUrlForEnvironment:env
                                                     version:version];
}

+ (NSURL *)getEmsBaseUrlForEnvironment:(TradeitEmsEnvironments)env
                               version:(TradeItEmsApiVersion)version {
    NSString *baseUrl = @"https://ems.tradingticket.com/api/";
    NSString *versionPath = @"v2/";

    switch (env) {
        case TradeItEmsProductionEnv:
            baseUrl = @"https://ems.tradingticket.com/api/";
            break;
        case TradeItEmsTestEnv:
            baseUrl = @"https://ems.qa.tradingticket.com/api/";
            break;
        case TradeItEmsLocalEnv:
            baseUrl = @"http://localhost:8080/api/";
            break;
        default:
            NSLog(@"Invalid environment %d - directing to production by default", env);
    }

    switch (version) {
        case TradeItEmsApiVersion_1:
            versionPath = @"v1/";
            break;
        case TradeItEmsApiVersion_2:
            versionPath = @"v2/";
            break;
        default:
            NSLog(@"Invalid version %d - directing to v2 by default", version);
    }

    baseUrl = [baseUrl stringByAppendingString:versionPath];

    return [NSURL URLWithString:baseUrl];
}

+ (NSMutableURLRequest *)buildJsonRequestForModel:(TIEMSJSONModel *)requestObject
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
    TIEMSJSONModelError *jsonModelError = nil;
    TradeItResult *resultFromJson = [tradeItResult initWithString:jsonString error:&jsonModelError];

    if (jsonModelError != nil)
    {
        NSLog(@"Received invalid json from ems server error=%@ response=%@", jsonModelError, jsonString);
        return [TradeItErrorResult tradeErrorWithSystemMessage:@"error parsing json response"];
    }

    return resultFromJson;
}

@end
