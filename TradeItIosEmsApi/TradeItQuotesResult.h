//
//  TradeItQuotesResult.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItResult.h"
#import "TradeItQuote.h"

@interface TradeItQuotesResult : TradeItResult

@property (nullable) NSArray<TradeItQuote, Optional> *quotes;

@end
