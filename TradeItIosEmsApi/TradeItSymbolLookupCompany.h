//
//  TradeItSymbolLookupCompany.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIEMSJSONModel.h"

@protocol TradeItSymbolLookupCompany
@end

@interface TradeItSymbolLookupCompany : TIEMSJSONModel<NSCopying>

// The company street symbol
@property (nullable, copy) NSString<Optional> *symbol;

// The company name
@property (nullable, copy) NSString<Optional> *name;

@end
