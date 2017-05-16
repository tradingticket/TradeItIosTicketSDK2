//
//  TradeItPublisherService.m
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 4/27/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItPublisherService.h"
#import "TradeItRequestResultFactory.h"

@implementation TradeItPublisherService

-(id) initWithConnector:(TradeItConnector *) connector {
    self = [super init];
    if(self) {
        self.connector = connector;
    }
    return self;
}

- (void)getAds:(TradeItAdsRequest *)request withCompletionBlock:(void(^)(TradeItResult *))completionBlock {
    NSString *endpoint = @"publisherad/getAdPlacements";
    request.apiKey = self.connector.apiKey;

    NSMutableURLRequest *adRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                 emsAction:endpoint
                                                                               environment:self.connector.environment];

    [self.connector sendEMSRequest:adRequest withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;

        if ([result.status isEqual:@"SUCCESS"]) {
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItAdsResult alloc]
                                                           jsonString:jsonResponse];
        }

        completionBlock(resultToReturn);
    }];
}

- (void) getBrokerCenter:(TradeItPublisherDataRequest *)request withCompletionBlock:(void(^)(TradeItResult *))completionBlock {
    NSString *endpoint = @"publisherad/getBrokerCenter";
    request.apiKey = self.connector.apiKey;

    NSMutableURLRequest *adRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                 emsAction:endpoint
                                                                               environment:self.connector.environment];

    [self.connector sendEMSRequest:adRequest
               withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;

        if ([result.status isEqual:@"SUCCESS"]){
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItBrokerCenterResult alloc]
                                                           jsonString:jsonResponse];
        }

        completionBlock(resultToReturn);
    }];
}

- (void)getPublisherData:(TradeItPublisherDataRequest *)request withCompletionBlock:(void(^)(TradeItResult *))completionBlock {
    NSString *endpoint = @"preference/getPublisherSDKData";
    request.apiKey = self.connector.apiKey;

    NSMutableURLRequest *adRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                 emsAction:endpoint
                                                                               environment:self.connector.environment];
    
    [self.connector sendEMSRequest:adRequest withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]){
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItPublisherDataResult alloc]
                                                           jsonString:jsonResponse];
        }

        completionBlock(resultToReturn);
    }];
}

@end
