//
//  TradeItBroker.h
//  TradeItIosEmsApi
//
//  Created by Alexander Kramer on 8/9/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TradeItBroker : NSObject

@property (nullable, copy) NSString *brokerShortName;

@property (nullable, copy) NSString *brokerLongName;

- (nonnull id)initWithShortName:(NSString * _Nullable)brokerShortName
                       longName:(NSString * _Nullable)brokerLongName;

@end
