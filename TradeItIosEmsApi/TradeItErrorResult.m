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
    if (self) {
        self.errorFields = nil;
        self.systemMessage = nil;
    }
    return self;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"TradeItErrorResult: %@ errorFields=%@ systemMessage=%@",[super description], self.errorFields, self.systemMessage];
}

+ (TradeItErrorResult *)errorWithSystemMessage:(NSString *)systemMessage {
    
    TradeItErrorResult *errorResult = [[TradeItErrorResult alloc] init];

    if (errorResult) {
        errorResult.status = @"ERROR";
        errorResult.code = @100; // TODO: Move this convenience method into the swift extension so enums can be used
        errorResult.shortMessage = @"Request failed";
        errorResult.systemMessage = systemMessage;
        errorResult.longMessages = @[@"Could not complete your request. Please try again."];
    }

    return errorResult;
}

@end
