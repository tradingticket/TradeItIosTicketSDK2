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
@property TradeItConnector * _Nullable connector;

/**
 *  Once the session has been established the session token is stored here.
 */
@property NSString * _Nullable token;

/**
 *  Recommended way to init as you'll always need a connector
 */
- (id _Nullable)initWithConnector:(TradeItConnector * _Nonnull)connector;

/**
 *  This will establish a session give the user's token and will set the userToken on the session.
 */
- (void)authenticate:(TradeItLinkedLogin * _Nullable)linkedLogin withCompletionBlock:(void (^ _Nonnull)(TradeItResult * _Nonnull))completionBlock;

/**
 *  Use this method to answer the broker secuirty question after the ems server sent a TradeItSecurityQuestionResult
 *
 *  @param answer security question answer
 *
 *  @param completionBlock Can either be TradeItStockOrEtfTradeReviewResult, TradeItSecurityQuestionResult or TradeItErrorResult. Caller needs to cast the result to the appropriate sub-class depending on the result status value. Note that TradeItSecurityQuestionResult will be returned again if the answer is incorrect.
 */
- (void)answerSecurityQuestion:(NSString * _Nullable)answer withCompletionBlock:(void (^ _Nonnull)(TradeItResult * _Nonnull))completionBlock;

- (void)answerSecurityQuestionPlaceOrder:(NSString * _Nullable)answer withCompletionBlock:(void (^ _Nonnull)(TradeItResult * _Nonnull))completionBlock;

/**
 *  Will close out the users current session and remove it from the TradeItSession instance.
 */
- (void)closeSession;

/**
 *  Use this method to answer the broker secuirty question after the ems server sent a TradeItSecurityQuestionResult
 *
 *  @param completionBlock Success indicates session still alive, TradeItErrorResult most commonly indicates the session has already expired, all error messages still apply though https://www.trade.it/api#ErrorHandling
 */
- (void)keepSessionAliveWithCompletionBlock:(void (^ _Nonnull)(TradeItResult * _Nonnull))completionBlock;

@end
