//
//  TradeItSession.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/15/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItSession.h"
#import "TradeItAuthenticationRequest.h"
#import "TradeItJsonConverter.h"
#import "TradeItAuthenticationResult.h"
#import "TradeItSecurityQuestionResult.h"
#import "TradeItSecurityQuestionRequest.h"
#import "TradeItBrokerAccount.h"

#ifdef CARTHAGE
#import <TradeItIosTicketSDK2Carthage/TradeItIosTicketSDK2Carthage-Swift.h>
#else
#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2-Swift.h>
#endif

@implementation TradeItSession

- (id)initWithConnector:(TradeItConnector *)connector {
    self = [super init];
    if (self) {
        self.connector = connector;
    }
    return self;
}

- (void)authenticate:(TradeItLinkedLogin *)linkedLogin withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    NSString *userToken = [self.connector userTokenFromKeychainId:linkedLogin.keychainId];
    TradeItAuthenticationRequest *authRequest = [[TradeItAuthenticationRequest alloc] initWithUserToken:userToken
                                                                                                 userId:linkedLogin.userId
                                                                                              andApiKey:self.connector.apiKey];

    NSMutableURLRequest *request = [TradeItJsonConverter buildJsonRequestForModel:authRequest
                                                                        emsAction:@"user/authenticate"
                                                                      environment:self.connector.environment];

    [self.connector sendEMSRequest:request
               withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        completionBlock([self parseAuthResponse:result
                                   jsonResponse:jsonResponse]);
    }];
}

- (void)answerSecurityQuestion:(NSString *)answer
           withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    TradeItSecurityQuestionRequest *secRequest = [[TradeItSecurityQuestionRequest alloc] initWithToken:self.token andAnswer:answer];

    NSMutableURLRequest *request = [TradeItJsonConverter buildJsonRequestForModel:secRequest
                                                                        emsAction:@"user/answerSecurityQuestion"
                                                                      environment:self.connector.environment];

    [self.connector sendEMSRequest:request
               withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        completionBlock([self parseAuthResponse:result
                                   jsonResponse:jsonResponse]);
    }];
}

- (TradeItResult *)parseAuthResponse:(TradeItResult *)authenticationResult
                        jsonResponse:(NSMutableString *)jsonResponse {
    self.token = [authenticationResult token];
    NSString *status = authenticationResult.status;

    TradeItResult *resultToReturn;

    if ([status isEqual:@"SUCCESS"]) {
        resultToReturn = [TradeItJsonConverter buildResult:[TradeItAuthenticationResult alloc] jsonString:jsonResponse];

    } else if ([status isEqualToString:@"INFORMATION_NEEDED"]) {
        resultToReturn = [TradeItJsonConverter buildResult:[TradeItSecurityQuestionResult alloc] jsonString:jsonResponse];
        
    } else if ([status isEqualToString:@"ERROR"]) {
        TradeItErrorResult *error = [TradeItErrorResult alloc];
        resultToReturn = [TradeItJsonConverter buildResult:error jsonString:jsonResponse];
    }

    return resultToReturn;
}

- (void)keepSessionAliveWithCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    NSLog(@"Implement me!!");
}

- (void)closeSession {
    NSLog(@"Implement me!!");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItSession: %@", self.token];
}

@end
