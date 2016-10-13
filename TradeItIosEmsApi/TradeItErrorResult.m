//
//  TradeItErrorResult.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/26/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItErrorResult.h"

@implementation TradeItErrorResult

- (id)init {
    self =  [super init];
    if(self){
        self.errorFields = nil;
        self.systemMessage = nil;
    }
    return self;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"TradeItErrorResult: %@ errorFields=%@ systemMessage=%@",[super description], self.errorFields, self.systemMessage];
}

+(TradeItErrorResult*) tradeErrorWithSystemMessage:(NSString*) systemMessage{
    
    TradeItErrorResult* errorResult = [[TradeItErrorResult alloc] init];
    if(errorResult){
        errorResult.shortMessage= @"Could Not Complete Your Order";
        errorResult.systemMessage = systemMessage;
        errorResult.longMessages = @[@"Trading is temporarily unavailable. Please try again in a few minutes."];
    }
    return errorResult;
}

@end
