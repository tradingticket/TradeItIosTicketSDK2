//
//  TradeItSession.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/15/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>
#import "TradeItSession.h"
#import "TradeItAuthenticationRequest.h"
#import "TradeItRequestResultFactory.h"
#import "TradeItErrorResult.h"
#import "TradeItAuthenticationResult.h"
#import "TradeItSecurityQuestionResult.h"
#import "TradeItSecurityQuestionRequest.h"
#import "TradeItBrokerAccount.h"
#import "TradeItErrorResult.h"

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
                                                                                              andApiKey:self.connector.apiKey
                                                                                       andAdvertisingId:[self getAdvertisingId]];

    NSMutableURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:authRequest
                                                                               emsAction:@"user/authenticate"
                                                                             environment:self.connector.environment];
    
    [self.connector sendEMSRequest:request
               withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        completionBlock([self parseAuthResponse:result
                                   jsonResponse:jsonResponse]);
    }];
}

- (NSString *)getAdvertisingId {
    if (TradeItSDK.isAdServiceEnabled) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    } else {
        return nil;
    }
}

- (void)answerSecurityQuestion:(NSString *)answer
           withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    TradeItSecurityQuestionRequest *secRequest = [[TradeItSecurityQuestionRequest alloc] initWithToken:self.token andAnswer:answer];

    NSMutableURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:secRequest
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
    NSString *status = authenticationResult.status;

    TradeItResult *resultToReturn;

    if ([status isEqual:@"SUCCESS"]) {
        self.token = [authenticationResult token];
        resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItAuthenticationResult alloc] jsonString:jsonResponse];

    } else if ([status isEqualToString:@"INFORMATION_NEEDED"]) {
        self.token = [authenticationResult token];
        resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItSecurityQuestionResult alloc] jsonString:jsonResponse];
        
    } else if ([status isEqualToString:@"ERROR"]) {
        resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItErrorResult alloc] jsonString:jsonResponse];
    }

    return resultToReturn;
}

- (void)keepSessionAliveWithCompletionBlock:(void (^)(TradeItResult *)) __unused completionBlock {
    NSLog(@"Implement me!!");
}

- (void)closeSession {
    NSLog(@"Implement me!!");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TradeItSession: %@", self.token];
}

@end
