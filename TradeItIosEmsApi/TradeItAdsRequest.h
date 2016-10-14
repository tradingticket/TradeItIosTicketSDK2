//
//  TradeItAdsRequest.h
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 4/27/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItRequest.h"

@interface TradeItAdsRequest : TradeItRequest

@property (copy) NSString * apiKey;
@property (copy) NSString * broker;

-(id) initWithApiKey:(NSString *)apiKey andBroker:(NSString *)broker;

@end
