//
//  TradeItSession.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/15/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItConnector.h"
#import "TradeItResult.h"
#import "TradeItLinkedLogin.h"

@interface TradeItSession : NSObject

/**
 *  Required property as the connector is used to make the requests to the EMS servers
 */
@property TradeItConnector *connector;

/**
 *  Once the session has been established the session token is stored here.
 */
@property NSString *token;

/**
 *  Recommended way to init as you'll always need a connector
 */
- (id)initWithConnector:(TradeItConnector *)connector;

/**
 *  This will establish a session give the user's token and will set the userToken on the session.
 *
 *  @param userToken obtained from an linkBrokerWithAuthenticationInfo
 *
 *  @return on success will return a list of TradeItBrokerAccount objects
 *  - It's also possible to recieve a TradeItSecurityQuestionResult in which you'll need to issue an answerSecurityQuestion request before you'll recieve the session token
 *  - TradeItErrorResult also possible please see https://www.trade.it/api#ErrorHandling for descriptions of error codes
 */
- (void)authenticate:(TradeItLinkedLogin *)linkedLogin withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

/**
 *  Use this method to answer the broker secuirty question after the ems server sent a TradeItSecurityQuestionResult
 *
 *  @param answer security question answer
 *
 *  @return TradeItResult. Can either be TradeItStockOrEtfTradeReviewResult, TradeItSecurityQuestionResult or TradeItErrorResult. Caller needs to cast the result to the appropriate sub-class depending on the result status value. Note that TradeItSecurityQuestionResult will be returned again if the answer is incorrect.
 */
- (void)answerSecurityQuestion:(NSString*)answer withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

/**
 *  Will close out the users current session and remove it from the TradeItSession instance.
 */
- (void)closeSession;

/**
 *  Use this method to answer the broker secuirty question after the ems server sent a TradeItSecurityQuestionResult
 *
 *  @return TradeItResult. Success indicates session still alive, TradeItErrorResult most commonly indicates the session has already expired, all error messages still apply though https://www.trade.it/api#ErrorHandling
 */
- (void)keepSessionAliveWithCompletionBlock:(void (^)(TradeItResult *))completionBlock;

@end
