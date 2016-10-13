//
//  TradeItBrokerCenterBroker.h
//  TradeItIosEmsApi
//
//  Created by Daniel Vaughn on 5/10/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@protocol TradeItBrokerCenterBroker
@end

@interface TradeItBrokerCenterBroker : TIEMSJSONModel<NSCopying>

@property (nullable, copy) NSNumber<Optional> *active;
@property (nullable, copy) NSString<Optional> *signupTitle;
@property (nullable, copy) NSString<Optional> *signupDescription;
@property (nullable, copy) NSString<Optional> *signupPostfix;
@property (nullable, copy) NSString<Optional> *accountMinimum;
@property (nullable, copy) NSString<Optional> *optionsOffer;
@property (nullable, copy) NSString<Optional> *optionsPostfix;
@property (nullable, copy) NSString<Optional> *stocksEtfsOffer;
@property (nullable, copy) NSString<Optional> *stocksEtfsPostfix;
@property (nullable, copy) NSString<Optional> *prompt;
@property (nullable, copy) NSString<Optional> *promptUrl;
@property (nullable, copy) NSArray<Optional> *backgroundColor;
@property (nullable, copy) NSArray<Optional> *textColor;
@property (nullable, copy) NSArray<Optional> *promptBackgroundColor;
@property (nullable, copy) NSArray<Optional> *promptTextColor;
@property (nullable, copy) NSDictionary<Optional> *logo;
@property (nullable, copy) NSArray<Optional> *disclaimers;
@property (nullable, copy) NSArray<Optional> *features;

@end
