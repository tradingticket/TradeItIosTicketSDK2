//
//  TradeItSecurityQuestionRequest.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/26/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItSecurityQuestionRequest : TradeItRequest

@property (nullable) NSString* token;
@property (nonnull) NSString* securityAnswer;

-(nonnull id) initWithToken:(NSString* _Nullable) token andAnswer:( NSString* _Nonnull )securityAnswer;

@end
