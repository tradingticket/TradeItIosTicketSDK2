//
//  TradeItSecurityQuestionRequest.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/26/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItSecurityQuestionRequest : TradeItRequest

@property NSString* token;
@property NSString* securityAnswer;

-(id) initWithToken:(NSString*) token andAnswer:(NSString*)securityAnswer;

@end
