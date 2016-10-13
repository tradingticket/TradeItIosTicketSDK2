//
//  TradeItPreviewTradeResult.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 1/30/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItPreviewTradeResult.h"

@implementation TradeItPreviewTradeResult

-(NSString *) description {
    return [NSString stringWithFormat:@"TradeItPreviewTradeResult - Warning List: %@  Acknowledgement List: %@  Order Details: %@", self.warningsList, self.ackWarningsList, self.orderDetails];
}

@end
