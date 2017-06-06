//
//  TradeItPositionService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/20/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItPositionService.h"
#import "TradeItRequestResultFactory.h"
#import "TradeItGetPositionsResult.h"

@implementation TradeItPositionService

-(id) initWithSession:(TradeItSession *) session {
    self = [super init];
    if(self) {
        self.session = session;
    }
    return self;
}

- (void) getAccountPositions:(TradeItGetPositionsRequest *) request withCompletionBlock:(void (^)(TradeItResult *)) completionBlock {
    request.token = self.session.token;
    
    NSMutableURLRequest *positionRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                       emsAction:@"position/getPositions"
                                                                                     environment:self.session.connector.environment];
    
    [self.session.connector sendEMSRequest:positionRequest withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]) {
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItGetPositionsResult alloc] jsonString:jsonResponse];
        }
        
        completionBlock(resultToReturn);
    }];
}

@end
