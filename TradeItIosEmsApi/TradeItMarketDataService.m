//
//  TradeItMarketDataService.m
//  TradeItIosEmsApi
//
//  Created by Antonio Reyes on 2/12/16.
//  Copyright © 2016 TradeIt. All rights reserved.
//

#import "TradeItMarketDataService.h"
#import "TradeItRequestResultFactory.h"
#import "TradeItQuotesResult.h"
#import "TradeItSymbolLookupResult.h"
#import "TradeItQuote.h"

@implementation TradeItMarketDataService

 -(id)initWithConnector:(TradeItConnector *)connector {
    self = [super init];
    if(self) {
        self.connector = connector;
    }
    return self;
}

- (void)getQuoteData:(TradeItQuotesRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    request.apiKey = self.connector.apiKey;

    NSString *endpoint;
    if (request.isFxMarket) {
        endpoint = @"brokermarketdata/getFxRate";
    } else if (request.suffixMarket) {
        endpoint = @"marketdata/getYahooQuotes";
    } else if (request.symbol) {
        endpoint = @"marketdata/getQuote";
    } else if (request.symbols) {
        endpoint = @"marketdata/getQuotes";
    } else {
        completionBlock(nil);
        return;
    }

    NSMutableURLRequest *quoteRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                    emsAction:endpoint
                                                                                  environment:self.connector.environment];

    [self.connector sendEMSRequest:quoteRequest withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;

        if ([result.status isEqual:@"SUCCESS"]) {
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItQuotesResult alloc] jsonString:jsonResponse];
        }

        completionBlock(resultToReturn);
    }];
}

- (void)symbolLookup:(TradeItSymbolLookupRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
    NSMutableURLRequest *symbolLookupRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
                                                                                           emsAction:@"marketdata/symbolLookup"
                                                                                         environment:self.connector.environment];
    
    [self.connector sendEMSRequest:symbolLookupRequest withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
        TradeItResult *resultToReturn = result;
        
        if ([result.status isEqual:@"SUCCESS"]) {
            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItSymbolLookupResult alloc] jsonString:jsonResponse];
        }

        completionBlock(resultToReturn);
    }];
}

- (void)getFxSymbols:(TradeItFxSymbolsRequest *)request withCompletionBlock:(void (^)(TradeItResult *))completionBlock {
//    NSMutableURLRequest *symbolLookupRequest = [TradeItRequestResultFactory buildJsonRequestForModel:request
//                                                                                           emsAction:@"marketdata/symbolLookup"
//                                                                                         environment:self.connector.environment];
//
//    [self.connector sendEMSRequest:symbolLookupRequest withCompletionBlock:^(TradeItResult *result, NSMutableString *jsonResponse) {
//        TradeItResult *resultToReturn = result;
//
//        if ([result.status isEqual:@"SUCCESS"]) {
//            resultToReturn = [TradeItRequestResultFactory buildResult:[TradeItSymbolLookupResult alloc] jsonString:jsonResponse];
//        }
//
//        completionBlock(resultToReturn);
//    }];
}

@end
