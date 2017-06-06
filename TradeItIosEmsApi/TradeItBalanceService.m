//
//  TradeItBalanceService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/20/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItBalanceService.h"
#import "TradeItRequestResultFactory.h"
#import "TradeItAccountOverviewResult.h"

@implementation TradeItBalanceService

- (id)initWithSession:(TradeItSession *)session {
    self = [super init];

    if(self) {
        self.session = session;
    }

    return self;
}

- (void)getAccountOverview:(TradeItAccountOverviewRequest *)request
       withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    request.token = self.session.token;

    NSMutableURLRequest *balanceRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                      emsAction:@"balance/getAccountOverview"
                                                                                    environment:self.session.connector.environment];
    
    [self.session.connector sendEMSRequest:balanceRequest
                       withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]) {
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItAccountOverviewResult alloc]
                                                           jsonString:jsonResponse];
        }
        
        completionBlock(resultToReturn);
    }];
}

@end
