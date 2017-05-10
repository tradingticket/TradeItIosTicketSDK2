//
//  TradeItStockOrEtfTradeReviewOrderDetails.m
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 6/23/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#import "TradeItPreviewTradeOrderDetails.h"

@implementation TradeItPreviewTradeOrderDetails

- (id)init {
    self = [super init];
    
    if (self) {
        self.orderSymbol = @"";
        self.orderAction = @"";
        self.orderQuantity = [NSNumber numberWithInt:0];
        self.orderExpiration = @"";
        self.orderPrice = @"";
        self.orderValueLabel = @"";
        self.orderMessage =  @"";
        self.lastPrice = nil;
        self.bidPrice = nil;
        self.askPrice = nil;
        self.timestamp = @"";
        self.buyingPower = nil;
        self.availableCash = nil;
        self.longHoldings = [NSNumber numberWithDouble:0.0];
        self.shortHoldings = [NSNumber numberWithDouble:0.0];
        self.estimatedOrderValue = nil;
        self.estimatedOrderCommission = nil;
        self.estimatedTotalValue = nil;
        
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"TradeItStockOrEtfReviewOrderDetails: orderSymbol=%@ orderAction=%@ orderPrice=%@ orderExpiration=%@ longHoldings=%@ shortHoldings=%@ orderQuantity=%@ buyingPower=%@ availableCash=%@ estimatedOrderValue=%@ estimatedOrderCommission=%@ estimatedTotalValue=%@ orderMessage=%@ orderValueLabel=%@", self.orderSymbol,self.orderAction,self.orderPrice,self.orderExpiration,self.longHoldings,self.shortHoldings,self.orderQuantity,self.buyingPower,self.availableCash,self.estimatedOrderValue,self.estimatedOrderCommission,self.estimatedTotalValue,self.orderMessage, self.orderValueLabel];
}

- (id)copyWithZone:(NSZone *)zone
{
    TradeItPreviewTradeOrderDetails *copy = [super copyWithZone:zone];
    
    if(copy){
        copy.orderSymbol=[self.orderSymbol copyWithZone:zone];
        copy.orderAction=[self.orderAction copyWithZone:zone];
        copy.orderQuantity= self.orderQuantity;
        copy.orderExpiration=[self.orderExpiration copyWithZone:zone];
        copy.orderPrice=[self.orderPrice copyWithZone:zone];
        copy.orderValueLabel=[self.orderValueLabel copyWithZone:zone];
        copy.orderMessage=[self.orderMessage copyWithZone:zone];
        copy.lastPrice=[self.lastPrice copyWithZone:zone];
        copy.bidPrice=[self.bidPrice copyWithZone:zone];
        copy.askPrice=[self.askPrice copyWithZone:zone];
        copy.timestamp=[self.timestamp copyWithZone:zone];
        copy.buyingPower=[self.buyingPower copyWithZone:zone];
        copy.availableCash=[self.availableCash copyWithZone:zone];
        copy.longHoldings=[self.longHoldings copyWithZone:zone];
        copy.shortHoldings=[self.shortHoldings copyWithZone:zone];
        copy.estimatedOrderValue=[self.estimatedOrderValue copyWithZone:zone];
        copy.estimatedOrderCommission=[self.estimatedOrderCommission copyWithZone:zone];
        copy.estimatedTotalValue=[self.estimatedTotalValue copyWithZone:zone];
    }
    return copy;
}


@end
