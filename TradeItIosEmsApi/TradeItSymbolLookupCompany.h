//
//  TradeItSymbolLookupCompany.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol TradeItSymbolLookupCompany
@end

@interface TradeItSymbolLookupCompany : JSONModel<NSCopying>

// The company street symbol
@property (nullable, copy) NSString<Optional> *symbol;

// The company name
@property (nullable, copy) NSString<Optional> *name;

@end
