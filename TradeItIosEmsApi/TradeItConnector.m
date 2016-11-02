//
//  TradeItConnector.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItConnector.h"
#import "TradeItJsonConverter.h"
#import "TradeItErrorResult.h"
#import "TradeItKeychain.h"
#import "TradeItAuthLinkRequest.h"
#import "TradeItBrokerListRequest.h"
#import "TradeItBrokerListResult.h"
#import "TradeItUpdateLinkRequest.h"
#import "TradeItUpdateLinkResult.h"

@implementation TradeItConnector {
    BOOL runAsyncCompletionBlockOnMainThread;
}

NSString * BROKER_LIST_KEYNAME = @"TRADEIT_BROKERS";
NSString * USER_DEFAULTS_SUITE = @"TRADEIT";

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

- (void)getAvailableBrokersWithCompletionBlock:(void (^ _Nullable)(NSArray<TradeItBroker *> * _Nullable))completionBlock {
    [self getAvailableBrokersJsonWithCompletionBlock:^void(NSArray *brokerDictionaries) {
        if (brokerDictionaries == nil) {
            completionBlock(nil);
        }

        NSMutableArray<TradeItBroker *> *brokers = [[NSMutableArray alloc] init];

        for (NSDictionary *brokerDictionary in brokerDictionaries) {
            TradeItBroker *broker = [[TradeItBroker alloc] initWithShortName:brokerDictionary[@"shortName"]
                                                                    longName:brokerDictionary[@"longName"]];
            [brokers addObject:broker];
        }

        completionBlock(brokers);
    }];
}

- (void)getAvailableBrokersJsonWithCompletionBlock:(void (^)(NSArray *))completionBlock {
    TradeItBrokerListRequest *brokerListRequest = [[TradeItBrokerListRequest alloc] initWithApiKey:self.apiKey];

    NSMutableURLRequest *request = [TradeItJsonConverter buildJsonRequestForModel:brokerListRequest
                                                                        emsAction:@"preference/getStocksOrEtfsBrokerList"
                                                                      environment:self.environment];
    
    [self sendEMSRequest:request withCompletionBlock:^(TradeItResult *tradeItResult, NSMutableString *jsonResponse) {
         if ([tradeItResult isKindOfClass: [TradeItErrorResult class]]) {
             NSLog(@"Could not fetch broker list, got error result%@ ", tradeItResult);
         } else if ([tradeItResult.status isEqual:@"SUCCESS"]){
             TradeItBrokerListResult *successResult = (TradeItBrokerListResult*)[TradeItJsonConverter buildResult:[TradeItBrokerListResult alloc]
                                                                                                       jsonString:jsonResponse];
             completionBlock(successResult.brokerList);
             
             return;
         }
         else if ([tradeItResult.status isEqual:@"ERROR"]){
             NSLog(@"Could not fetch broker list, got error result%@ ", tradeItResult);
         }
         
         completionBlock(nil);
    }];
}

- (void)linkBrokerWithAuthenticationInfo:(TradeItAuthenticationInfo *)authInfo
                      andCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    TradeItAuthLinkRequest *authLinkRequest = [[TradeItAuthLinkRequest alloc] initWithAuthInfo:authInfo andAPIKey:self.apiKey];
    
    NSMutableURLRequest *request = [TradeItJsonConverter buildJsonRequestForModel:authLinkRequest
                                                                        emsAction:@"user/oAuthLink"
                                                                      environment:self.environment];
    
    [self sendEMSRequest:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSMutableString *jsonResponse) {
        if ([tradeItResult.status isEqual:@"SUCCESS"]) {
            TradeItAuthLinkResult *successResult = (TradeItAuthLinkResult*)[TradeItJsonConverter buildResult:[TradeItAuthLinkResult alloc]
                                                                                                  jsonString:jsonResponse];
            tradeItResult = successResult;
        }
        
        completionBlock(tradeItResult);
    }];
}

- (void)updateUserToken:(TradeItLinkedLogin *)linkedLogin
               authInfo:(TradeItAuthenticationInfo *)authInfo
     andCompletionBlock:(void (^)(TradeItResult *))completionBlock {

    TradeItUpdateLinkRequest *updateLinkRequest = [[TradeItUpdateLinkRequest alloc] initWithUserId:linkedLogin.userId
                                                                                          authInfo:authInfo
                                                                                            apiKey:self.apiKey];

    NSMutableURLRequest *request = [TradeItJsonConverter buildJsonRequestForModel:updateLinkRequest
                                                                        emsAction:@"user/oAuthUpdate"
                                                                      environment:self.environment];

    [self sendEMSRequest:request
     withCompletionBlock:^(TradeItResult *tradeItResult, NSMutableString *jsonResponse) {
         if ([tradeItResult.status isEqual:@"SUCCESS"]) {
             TradeItUpdateLinkResult* successResult = (TradeItUpdateLinkResult *)[TradeItJsonConverter buildResult:[TradeItUpdateLinkResult alloc]
                                                                                                        jsonString:jsonResponse];
             tradeItResult = successResult;
         }

         completionBlock(tradeItResult);
     }];

}

- (TradeItLinkedLogin *)updateLinkInKeychain:(TradeItUpdateLinkResult *)link
                                  withBroker:(NSString *)broker {
    NSDictionary *linkDict = [self getLinkedLoginDictByuserId:link.userId];

    if (linkDict) {
        // If the saved link is found, update the token in the keychain for its keychainId
        NSString *keychainId = linkDict[@"keychainId"];

        [TradeItKeychain saveString:link.userToken forKey:keychainId];
        
        return [[TradeItLinkedLogin alloc] initWithLabel:linkDict[@"label"]
                                                  broker:broker
                                                  userId:link.userId
                                           andKeyChainId:keychainId];
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
    NSUserDefaults *standardUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULTS_SUITE];
    NSMutableArray *accounts = [[NSMutableArray alloc] initWithArray:[self getLinkedLoginsRaw]];
    NSString *keychainId = [[NSUUID UUID] UUIDString];
    
    NSDictionary *newRecord = @{@"label":label,
                                 @"broker":broker,
                                 @"userId":link.userId,
                                 @"keychainId":keychainId};

    [accounts addObject:newRecord];
    
    [standardUserDefaults setObject:accounts forKey:BROKER_LIST_KEYNAME];
    
    [TradeItKeychain saveString:link.userToken forKey:keychainId];
    
    return [[TradeItLinkedLogin alloc] initWithLabel:label
                                              broker:broker
                                              userId:link.userId
                                       andKeyChainId:keychainId];
}

- (NSDictionary *)getLinkedLoginDictByuserId:(NSString *)userId {
    NSArray *linkedLoginDicts = [self getLinkedLoginsRaw];

    // Search for the existing saved link by userId
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *linkDict, NSDictionary *bindings) {
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
    NSUserDefaults *standardUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULTS_SUITE];
    NSArray *linkedAccounts = [standardUserDefaults arrayForKey:BROKER_LIST_KEYNAME];
    
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
                                                                andKeyChainId:account[@"keychainId"]]];
    }
    
    return accountsToReturn;
}

- (void)unlinkBroker:(NSString *)broker {
    NSUserDefaults *standardUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULTS_SUITE];
    NSMutableArray *accounts = [[NSMutableArray alloc] initWithArray:[self getLinkedLoginsRaw]];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    [accounts enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *account = (NSDictionary *) obj;
        if([account[@"broker"] isEqualToString:broker]) {
            [toRemove addObject:obj];
        }
    }];
    
    for (NSDictionary *account in toRemove) {
        [accounts removeObject:account];
    }
    
    [standardUserDefaults setObject:accounts forKey:BROKER_LIST_KEYNAME];
}

- (void)unlinkLogin:(TradeItLinkedLogin *)login {
    NSUserDefaults *standardUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULTS_SUITE];
    NSMutableArray *accounts = [[NSMutableArray alloc] initWithArray:[self getLinkedLoginsRaw]];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];

    [accounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *account = (NSDictionary *)obj;
        if ([account[@"userId"] isEqualToString: login.userId]) {
            [toRemove addObject:obj];
        }
    }];
    
    for (NSDictionary * account in toRemove) {
        [accounts removeObject:account];
    }
    
    [standardUserDefaults setObject:accounts forKey:BROKER_LIST_KEYNAME];
}

- (NSString *)userTokenFromKeychainId:(NSString *)keychainId {
    return [TradeItKeychain getStringForKey:keychainId];
}

-(void) sendEMSRequest:(NSMutableURLRequest *)request
   withCompletionBlock:(void (^)(TradeItResult *, NSMutableString *))completionBlock {

    /*
    NSLog(@"----------New Request----------");
    NSLog([[request URL] absoluteString]);
    NSString *data = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSLog(data);
    */

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *responseJsonData = [NSURLConnection sendSynchronousRequest:request
                                                         returningResponse:&response
                                                                     error:&error];

        if ((responseJsonData == nil) || ([response statusCode] != 200)) {
            //error occured
            NSLog(@"ERROR from EMS server response=%@ error=%@", response, error);
            TradeItErrorResult *errorResult = [TradeItErrorResult tradeErrorWithSystemMessage:@"error sending request to ems server"];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completionBlock(errorResult, nil);
            });

            return;
        }
        
        NSMutableString *jsonResponse = [[NSMutableString alloc] initWithData:responseJsonData encoding:NSUTF8StringEncoding];

        /*
        NSLog(@"----------Response %@----------", [[request URL] absoluteString]);
        NSLog(jsonResponse);
        */

        //first convert to a generic result to check the type
        TradeItResult *tradeItResult = [TradeItJsonConverter buildResult:[TradeItResult alloc]
                                                               jsonString:jsonResponse];
        
        if ([tradeItResult.status isEqual:@"ERROR"]) {
            TradeItErrorResult * errorResult;
            
            if (![tradeItResult isKindOfClass:[TradeItErrorResult class]]) {
                errorResult = (TradeItErrorResult *)[TradeItJsonConverter buildResult:[TradeItErrorResult alloc]
                                                                           jsonString:jsonResponse];
            } else {
                errorResult = (TradeItErrorResult *) tradeItResult; //this type of error caused by something wrong parsing the response
            }
            
            tradeItResult = errorResult;
        }
        
        dispatch_async(dispatch_get_main_queue(),^(void){completionBlock(tradeItResult, jsonResponse);});
    });
}

@end
