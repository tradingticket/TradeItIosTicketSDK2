//
//  TradeItSecurityQuestionResult.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/24/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItSecurityQuestionResult.h"


@implementation TradeItSecurityQuestionResult

- (id) init{
    
    self = [super init];
    
    if(self){
        self.securityQuestion  = nil;
        self.securityQuestionOptions = nil;
        self.challengeImage = nil;
    }
    return self;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"TradeItSecurityQuestionResult: %@ securityQuestion=%@ securityQuestionOptions=%@ challengeImage=%@",[super description], self.securityQuestion,self.securityQuestionOptions,self.challengeImage ];
}

@end
