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

- (NSString*) description {
    return [NSString stringWithFormat:@"TradeItErrorResult: %@ code=%@ errorFields=%@ systemMessage=%@",
            [super description],
            self.code,
            self.errorFields,
            self.systemMessage];
}

@end
