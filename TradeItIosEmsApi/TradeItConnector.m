//
//  TradeItConnector.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItConnector.h"
#import "TradeItRequestResultFactory.h"
#import "TradeItErrorResult.h"
#import "TradeItKeychain.h"
#import "TradeItAuthLinkRequest.h"
#import "TradeItBrokerListRequest.h"
#import "TradeItBrokerListResult.h"
#import "TradeItUpdateLinkRequest.h"
#import "TradeItUpdateLinkResult.h"
#import "TradeItOAuthLoginPopupUrlForMobileRequest.h"
#import "TradeItOAuthLoginPopupUrlForMobileResult.h"
#import "TradeItOAuthAccessTokenRequest.h"
#import "TradeItOAuthAccessTokenResult.h"
#import "TradeItOAuthLoginPopupUrlForTokenUpdateRequest.h"
#import "TradeItOAuthLoginPopupUrlForTokenUpdateResult.h"
#import "TradeItOAuthDeleteLinkRequest.h"
#import "TradeItParseErrorResult.h"
#import "TradeItUnlinkLoginResult.h"

#ifdef CARTHAGE
#import <TradeItIosTicketSDK2Carthage/TradeItIosTicketSDK2Carthage-Swift.h>
#else
#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2-Swift.h>
#endif

@interface TradeItConnector()

- (NSUserDefaults *)userDefaults;
- (void)oAuthDeleteLink:(TradeItLinkedLogin *)linkedLogin
        withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

@end

@implementation TradeItConnector {
    BOOL runAsyncCompletionBlockOnMainThread;
}

NSString *BROKER_LIST_KEYNAME = @"TRADEIT_BROKERS";
NSString *USER_DEFAULTS_SUITE = @"TRADEIT";

- (NSUserDefaults *)userDefaults {
    static NSUserDefaults *userDefaults = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULTS_SUITE];
    });

    return userDefaults;
}

- (id)initWithApiKey:(NSString *)apiKey
         environment:(TradeitEmsEnvironments)environment
             version:(TradeItEmsApiVersion)version {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.environment = environment;
        self.version = version;
        runAsyncCompletionBlockOnMainThread = true;
    }

    return self;
}

- (id)initWithApiKey:(NSString *)apiKey {
    self = [super init];

    if (self) {
        self.apiKey = apiKey;
        self.environment = TradeItEmsProductionEnv;
        self.version = TradeItEmsApiVersion_2;
        runAsyncCompletionBlockOnMainThread = true;
    }

    return self;
}

// TODO: Extract and Swiftify to OAuthService
- (void)getOAuthLoginPopupUrlForMobileWithBroker:(NSString *)broker
                                oAuthCallbackUrl:(NSURL *)oAuthCallbackUrl
                                 completionBlock:(void (^)(TradeItResult *))completionBlock {

    TradeItOAuthLoginPopupUrlForMobileRequest *oAuthLoginPopupUrlForMobileRequest
    = [[TradeItOAuthLoginPopupUrlForMobileRequest alloc] initWithApiKey:self.apiKey
                                                                 broker:broker
                                                interAppAddressCallback:[oAuthCallbackUrl absoluteString]];

    NSURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:oAuthLoginPopupUrlForMobileRequest
                                                                               emsAction:@"user/getOAuthLoginPopupUrlForMobile"
                                                                             environment:self.environment];

    [self sendReturnJSON:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSString *jsonResponse) {
         if ([tradeItResult isSuccessful]) {
             TradeItOAuthLoginPopupUrlForMobileResult *successResult
             = (TradeItOAuthLoginPopupUrlForMobileResult *)[TradeItRequestResultFactory buildResult:[TradeItOAuthLoginPopupUrlForMobileResult alloc]
                                                                                         jsonString:jsonResponse];
             tradeItResult = successResult;
         }

         completionBlock(tradeItResult);
     }];
}

// TODO: Extract and Swiftify to OAuthService
- (void)getOAuthLoginPopupURLForTokenUpdateWithBroker:(NSString *)broker
                                               userId:(NSString *)userId
                                     oAuthCallbackUrl:(NSURL *)oAuthCallbackUrl
                                      completionBlock:(void (^)(TradeItResult *))completionBlock {

    TradeItOAuthLoginPopupUrlForTokenUpdateRequest *oAuthLoginPopupUrlForTokenUpdateRequest
    = [[TradeItOAuthLoginPopupUrlForTokenUpdateRequest alloc] initWithApiKey:self.apiKey
                                                                      broker:broker
                                                                      userId:userId
                                                     interAppAddressCallback:[oAuthCallbackUrl absoluteString]];

    NSURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:oAuthLoginPopupUrlForTokenUpdateRequest
                                                                               emsAction:@"user/getOAuthLoginPopupURLForTokenUpdate"
                                                                             environment:self.environment];

    [self sendReturnJSON:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSString *jsonResponse) {
         if ([tradeItResult isSuccessful]) {
             TradeItOAuthLoginPopupUrlForTokenUpdateResult *successResult
             = (TradeItOAuthLoginPopupUrlForTokenUpdateResult *)[TradeItRequestResultFactory buildResult:[TradeItOAuthLoginPopupUrlForTokenUpdateResult alloc]
                                                                                              jsonString:jsonResponse];
             tradeItResult = successResult;
         }

         completionBlock(tradeItResult);
     }];
}

// TODO: Extract and Swiftify to OAuthService
- (void)getOAuthAccessTokenWithOAuthVerifier:(NSString *)oAuthVerifier
                             completionBlock:(void (^)(TradeItResult *))completionBlock {

    TradeItOAuthAccessTokenRequest *oAuthAccessTokenRequest
    = [[TradeItOAuthAccessTokenRequest alloc] initWithApiKey:self.apiKey
                                               oAuthVerifier:oAuthVerifier];

    NSURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:oAuthAccessTokenRequest
                                                                               emsAction:@"user/getOAuthAccessToken"
                                                                             environment:self.environment];

    [self sendReturnJSON:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSString *jsonResponse) {
         if ([tradeItResult isSuccessful]) {
             TradeItOAuthAccessTokenResult *successResult
             = (TradeItOAuthAccessTokenResult *)[TradeItRequestResultFactory buildResult:[TradeItOAuthAccessTokenResult alloc]
                                                                              jsonString:jsonResponse];
             tradeItResult = successResult;
         }

         completionBlock(tradeItResult);
     }];
}

// TODO: Deprecated - should be using OAuth
- (void)linkBrokerWithAuthenticationInfo:(TradeItAuthenticationInfo *)authInfo
                      andCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    TradeItAuthLinkRequest *authLinkRequest = [[TradeItAuthLinkRequest alloc] initWithAuthInfo:authInfo andAPIKey:self.apiKey];

    NSURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:authLinkRequest
                                                                               emsAction:@"user/oAuthLink"
                                                                             environment:self.environment];

    [self sendReturnJSON:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSString *jsonResponse) {
         if ([tradeItResult isSuccessful]) {
             TradeItAuthLinkResult *successResult
             = (TradeItAuthLinkResult*)[TradeItRequestResultFactory buildResult:[TradeItAuthLinkResult alloc]
                                                                     jsonString:jsonResponse];
             tradeItResult = successResult;
         }

         completionBlock(tradeItResult);
     }];
}

// TODO: Extract and Swiftify to OAuthService
- (void)updateUserToken:(TradeItLinkedLogin *)linkedLogin
               authInfo:(TradeItAuthenticationInfo *)authInfo
     andCompletionBlock:(void (^)(TradeItResult *))completionBlock {

    TradeItUpdateLinkRequest *updateLinkRequest = [[TradeItUpdateLinkRequest alloc] initWithUserId:linkedLogin.userId
                                                                                          authInfo:authInfo
                                                                                            apiKey:self.apiKey];

    NSURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:updateLinkRequest
                                                                               emsAction:@"user/oAuthUpdate"
                                                                             environment:self.environment];

    [self sendReturnJSON:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSString *jsonResponse) {
         if ([tradeItResult isSuccessful]) {
             TradeItUpdateLinkResult *successResult
             = (TradeItUpdateLinkResult *)[TradeItRequestResultFactory buildResult:[TradeItUpdateLinkResult alloc]
                                                                        jsonString:jsonResponse];
             tradeItResult = successResult;
         }

         completionBlock(tradeItResult);
     }];

}

- (TradeItLinkedLogin *)updateKeychainWithLink:(TradeItAuthLinkResult *)link
                                    withBroker:(NSString *)broker {
    NSDictionary *linkDict = [self getLinkedLoginDictByuserId:link.userId];

    if (linkDict) {
        // If the saved link is found, update the token in the keychain for its keychainId
        NSString *keychainId = linkDict[@"keychainId"];

        [TradeItKeychain saveString:link.userToken forKey:keychainId];

        return [[TradeItLinkedLogin alloc] initWithLabel:linkDict[@"label"]
                                                  broker:broker
                                                  userId:link.userId
                                              keyChainId:keychainId];
    } else {
        // No existing link for that userId so make a new one
        TradeItAuthLinkResult *authLinkResult = [[TradeItAuthLinkResult alloc] init];
        authLinkResult.userId = link.userId;
        authLinkResult.userToken = link.userToken;

        return [self saveToKeychainWithLink:authLinkResult
                                 withBroker:broker];
    }
}

- (TradeItLinkedLogin *)saveToKeychainWithLink:(TradeItAuthLinkResult *)link
                                    withBroker:(NSString *)broker {
    return [self saveToKeychainWithLink:link withBroker:broker andLabel:broker];
}

- (TradeItLinkedLogin *)saveToKeychainWithLink:(TradeItAuthLinkResult *)link
                                    withBroker:(NSString *)broker
                                      andLabel:(NSString *)label {
    return [self saveToKeychainWithUserId:link.userId andUserToken:link.userToken andBroker:broker andLabel:label];
}

- (TradeItLinkedLogin *)saveToKeychainWithUserId:(NSString *)userId
                                    andUserToken:(NSString *)userToken
                                       andBroker:(NSString *)broker
                                        andLabel:(NSString *)label {
    NSMutableArray *accounts = [[NSMutableArray alloc] initWithArray:[self getLinkedLoginsRaw]];
    NSString *keychainId = [[NSUUID UUID] UUIDString];

    NSDictionary *newRecord = @{@"label":label,
                                @"broker":broker,
                                @"userId":userId,
                                @"keychainId":keychainId};

    [accounts addObject:newRecord];

    [self.userDefaults setObject:accounts forKey:BROKER_LIST_KEYNAME];

    [TradeItKeychain saveString:userToken forKey:keychainId];

    return [[TradeItLinkedLogin alloc] initWithLabel:label
                                              broker:broker
                                              userId:userId
                                          keyChainId:keychainId];
}

- (NSDictionary *)getLinkedLoginDictByuserId:(NSString *)userId {
    NSArray *linkedLoginDicts = [self getLinkedLoginsRaw];

    // Search for the existing saved link by userId
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *linkDict, NSDictionary * __unused bindings) {
        return [linkDict[@"userId"] isEqual:userId];
    }];

    NSArray *filteredLinkDicts = [linkedLoginDicts filteredArrayUsingPredicate:filter];

    if (filteredLinkDicts.count > 0) {
        // Link found
        return filteredLinkDicts[0];
    } else {
        // Link not found
        return nil;
    }
}

- (NSArray *)getLinkedLoginsRaw {
    NSArray *linkedAccounts = [self.userDefaults arrayForKey:BROKER_LIST_KEYNAME];

    if (!linkedAccounts) {
        linkedAccounts = [[NSArray alloc] init];
    }

    /*
     NSLog(@"------------Linked Logins-------------");
     [linkedAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     NSDictionary * account = (NSDictionary *) obj;
     NSLog(@"Broker: %@ - Label: %@ - UserId: %@ - KeychainId: %@", account[@"broker"], account[@"label"], account[@"userId"], account[@"keychainId"]);
     }];
     */

    return linkedAccounts;
}

- (NSArray *)getLinkedLogins {
    NSArray *linkedAccounts = [self getLinkedLoginsRaw];

    NSMutableArray *accountsToReturn = [[NSMutableArray alloc] init];
    for (NSDictionary *account in linkedAccounts) {
        [accountsToReturn addObject:[[TradeItLinkedLogin alloc] initWithLabel:account[@"label"]
                                                                       broker:account[@"broker"]
                                                                       userId:account[@"userId"]
                                                                   keyChainId:account[@"keychainId"]]];
    }

    return accountsToReturn;
}

- (void)unlinkLogin:(TradeItLinkedLogin *)login
          localOnly:(BOOL)localOnly
withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    if (localOnly) {
        [self deleteLocalLinkedLogin:login];

        TradeItUnlinkLoginResult *successResult = [[TradeItUnlinkLoginResult alloc] init];
        successResult.status = @"SUCCESS";
        successResult.shortMessage = @"Broker succesfully unlinked";
        completionBlock(successResult);
    } else {
        [self oAuthDeleteLink:login
          withCompletionBlock:^void(TradeItResult *result) {
              if ([result isSuccessful]) {
                  [self deleteLocalLinkedLogin:login];
              }

              completionBlock(result);
        }];
    }
}

// UNEXPOSED METHOD
- (void)deleteLocalLinkedLogin:(TradeItLinkedLogin *)login {
    NSMutableArray *accounts = [[NSMutableArray alloc] initWithArray:[self getLinkedLoginsRaw]];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];

    [accounts enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull __unused stop) {
        NSDictionary *account = (NSDictionary *)obj;
        if ([account[@"userId"] isEqualToString:login.userId]) {
            [toRemove addObject:obj];
        }
    }];

    for (NSDictionary *account in toRemove) {
        [accounts removeObject:account];
    }

    [self.userDefaults setObject:accounts forKey:BROKER_LIST_KEYNAME];
}

- (NSString *)userTokenFromKeychainId:(NSString *)keychainId {
    return [TradeItKeychain getStringForKey:keychainId];
}

// TODO: Extract and Swiftify to OAuthService
- (void)oAuthDeleteLink:(TradeItLinkedLogin *)linkedLogin
    withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    NSString *userToken = [self userTokenFromKeychainId:linkedLogin.keychainId];

    TradeItOAuthDeleteLinkRequest *oAuthDeleteLinkRequest = [[TradeItOAuthDeleteLinkRequest alloc] init];
    oAuthDeleteLinkRequest.apiKey = self.apiKey;
    oAuthDeleteLinkRequest.userId = linkedLogin.userId;
    oAuthDeleteLinkRequest.userToken = userToken;

    NSURLRequest *request = [TradeItRequestResultFactory buildJsonRequestForModel:oAuthDeleteLinkRequest
                                                                               emsAction:@"user/oAuthDelete"
                                                                             environment:self.environment];

    [self sendReturnJSON:request withCompletionBlock:^(TradeItResult * __unused tradeItResult, NSString * __unused jsonResponse) {
        if ([tradeItResult isSuccessful]) {
            TradeItUnlinkLoginResult *successResult
            = (TradeItUnlinkLoginResult *)[TradeItRequestResultFactory buildResult:[TradeItUnlinkLoginResult alloc]
                                                                        jsonString:jsonResponse];
            tradeItResult = successResult;
        }
        
        completionBlock(tradeItResult);
    }];
}

@end
