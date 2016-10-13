//
//  TradeItAccountOverviewResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/3/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItResult.h"
#import "TradeItAccountOverview.h"
#import "TradeItFxAccountOverview.h"

@interface TradeItAccountOverviewResult : TradeItResult

@property (nullable, copy) TradeItAccountOverview<Optional> *accountOverview;

@property (nullable, copy) TradeItFxAccountOverview<Optional> *fxAccountOverview;

@end
