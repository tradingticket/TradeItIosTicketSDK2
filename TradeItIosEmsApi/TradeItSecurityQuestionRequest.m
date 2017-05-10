//
//  TradeItSecurityQuestionRequest.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/26/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItSecurityQuestionRequest.h"

@implementation TradeItSecurityQuestionRequest

-(id) initWithToken:(NSString*) token andAnswer:(NSString*)securityAnswer{
    self = [super init];
    if(self){
        self.token = token;
        self.securityAnswer = securityAnswer;
    }
    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"TradeItSecurityQuestionRequest: %@ token:%@ securityAnswer:%@", [super description], self.token, self.securityAnswer];
}

@end
