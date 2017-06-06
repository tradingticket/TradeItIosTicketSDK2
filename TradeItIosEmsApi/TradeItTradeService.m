//
//  TradeItTradeService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/15/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItTradeService.h"
#import "TradeItRequestResultFactory.h"
#import "TradeItPreviewTradeResult.h"
#import "TradeItPlaceTradeResult.h"

@implementation TradeItTradeService

- (id)initWithSession:(TradeItSession *) session {
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

- (void)previewTrade:(TradeItPreviewTradeRequest *)order withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    order.token = self.session.token;
    
    NSMutableURLRequest * request = [TradeItRequestResultFactory buildJsonRequestForModel:order
                                                                                emsAction:@"order/previewStockOrEtfOrder"
                                                                              environment:self.session.connector.environment];

    [self.session.connector sendEMSRequest:request
                       withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;
        
        if ([result.status isEqual:@"REVIEW_ORDER"]){
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItPreviewTradeResult alloc]
                                                           jsonString:jsonResponse];
        }

        completionBlock(resultToReturn);
    }];
}

- (void)placeTrade:(TradeItPlaceTradeRequest *)order withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    order.token = self.session.token;
    
    NSMutableURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:order
                                                                               emsAction:@"order/placeStockOrEtfOrder"
                                                                             environment:self.session.connector.environment];

    [self.session.connector sendEMSRequest:request withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]) {
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItPlaceTradeResult alloc]
                                                           jsonString:jsonResponse];
        }
        
        completionBlock(resultToReturn);
    }];
}

@end
