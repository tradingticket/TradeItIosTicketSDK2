//
//  TradeItAccountOverviewRequest.h
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/3/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TradeItRequest.h"

@interface TradeItAccountOverviewRequest : TradeItRequest

// Init with account number, preferred as accountNumber is required
-(id) initWithAccountNumber:(NSString *) accountNumber;


// Set the account number, required
@property (copy) NSString * accountNumber;



// Session Token - Will be set by the session associated with the request
// Setting this here will be overriden
@property (copy) NSString * token;

@end
