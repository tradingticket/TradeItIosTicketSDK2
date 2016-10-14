//
//  TradeItFxAccountOverview.h
//  TradeItIosEmsApi
//
//  Created by Guillaume Debavelaere on 8/25/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TIEMSJSONModel.h"

@interface TradeItFxAccountOverview : TIEMSJSONModel

@property (nullable, copy) NSNumber<Optional> *totalValueBaseCurrency;

@property (nullable, copy) NSNumber<Optional> *totalValueUSD;

@property (nullable, copy) NSNumber<Optional> *buyingPowerBaseCurrency;

@property (nullable, copy) NSNumber<Optional> *unrealizedProfitAndLossBaseCurrency;

@property (nullable, copy) NSNumber<Optional> *realizedProfitAndLossBaseCurrency;

@property (nullable, copy) NSNumber<Optional> *marginBalanceBaseCurrency;

@end
