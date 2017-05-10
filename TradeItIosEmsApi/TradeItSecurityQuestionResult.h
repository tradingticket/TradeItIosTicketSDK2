//
//  TradeItSecurityQuestionResult.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/24/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//


#import "TradeItResult.h"

/**
 *  Returned if the user needs to answer a security question before interacting with her account.
 */
@interface TradeItSecurityQuestionResult : TradeItResult

/**
 *  The security question to ask the user
 */
@property (nullable, copy) NSString *securityQuestion;

/**
 *  An array of options if it's a multiple choice question. nil or emtpy array if broker does not provide any options
 */
@property (nullable) NSArray<NSString *><Optional> *securityQuestionOptions;

/**
 *  A base64 encoded image to be displayed to the user for security code card lookup (like a captcha)
 *  nil or empty string if broker does not provide challenge image
 */
@property (nullable, copy) NSString<Optional> *challengeImage; //nil if broker does not provide challenge image

@end
