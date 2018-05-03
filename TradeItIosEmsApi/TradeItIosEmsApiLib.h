//
//  TradeItIosEmsApiLib.h
//  TradeItIosEmsApi
//
//  Created by Serge Kreiker on 7/8/15.
//  Copyright (c) 2015 TradeIt. All rights reserved.
//

#ifndef TradeItIosEmsApi_TradeItIosEmsApiLib_h
#define TradeItIosEmsApi_TradeItIosEmsApiLib_h

// Generic classes for the request/results sent the to EMS server
#import "TradeItRequest.h"
#import "TradeItResult.h"
#import "TradeItErrorResult.h"
#import "TradeItKeychain.h"

// Start with the connector, you'll set your API key and the environment
// Then link a user to their brokerage(s) account(s)
#import "TradeItConnector.h"
#import "TradeItLinkedLogin.h"
#import "TradeItAuthenticationInfo.h"
#import "TradeItAuthenticationRequest.h"
#import "TradeItAuthenticationResult.h"
#import "TradeItAuthLinkRequest.h"
#import "TradeItAuthLinkResult.h"
#import "TradeItUpdateLinkRequest.h"
#import "TradeItBroker.h"
#import "TradeItBrokerAccount.h"
#import "TradeItSymbolLookupRequest.h"
#import "TradeItBrokerListRequest.h"
#import "TradeItOAuthLoginPopupUrlForMobileRequest.h"
#import "TradeItOAuthLoginPopupUrlForMobileResult.h"
#import "TradeItOAuthAccessTokenRequest.h"
#import "TradeItOAuthAccessTokenResult.h"
#import "TradeItOAuthLoginPopupUrlForTokenUpdateRequest.h"
#import "TradeItOAuthLoginPopupUrlForTokenUpdateResult.h"
#import "TradeItUnlinkLoginResult.h"
#import "TradeItOAuthDeleteLinkRequest.h"

// Once you have a link you'll establish a session using the linkedLogin
#import "TradeItSecurityQuestionRequest.h"
#import "TradeItSecurityQuestionResult.h"
#import "TradeItQuotesRequest.h"
#import "TradeItQuotesResult.h"
#import "TradeItQuote.h"

// Use the TradeService to preview and place trades
#import "TradeItPreviewTradeRequest.h"
#import "TradeItPreviewTradeOrderDetails.h"
#import "TradeItPreviewTradeResult.h"
#import "TradeItPreviewMessage.h"
#import "TradeItPreviewMessageLink.h"
#import "TradeItPlaceTradeRequest.h"
#import "TradeItPlaceTradeResult.h"
#import "TradeItPlaceTradeOrderInfo.h"
#import "TradeItPlaceTradeOrderInfoPrice.h"
#import "TradeItSymbolLookupCompany.h"
#import "TradeItSymbolLookupResult.h"
#import "TradeItFxPlaceOrderRequest.h"
#import "TradeItFxOrderInfoInput.h"
#import "TradeItFxOrderLeg.h"
#import "TradeItFxPlaceOrderResult.h"
#import "TradeItFxSymbolsRequest.h"
#import "TradeItOrderCapabilitiesRequest.h"
#import "TradeItFxOrderCapabilities.h"
#import "TradeItFxOrderCapabilitiesResult.h"
#import "TradeItFxQuoteRequest.h"
#import "TradeItInstrumentActionCapability.h"

// Use the BalanceService to get account balance information
#import "TradeItAccountOverviewRequest.h"
#import "TradeItAccountOverviewResult.h"
#import "TradeItAccountOverview.h"
#import "TradeItFxAccountOverview.h"

// Use the PositionSerview to get account position information
#import "TradeItGetPositionsRequest.h"
#import "TradeItGetPositionsResult.h"
#import "TradeItPosition.h"
#import "TradeItFxPosition.h"

// UI Config
#import "TradeItUiConfigRequest.h"
#import "TradeItUiConfigResult.h"

// Order status
#import "TradeItAllOrderStatusRequest.h"
#import "TradeItAllOrderStatusResult.h"
#import "TradeItOrderStatusDetails.h"
#import "TradeItOrderLeg.h"
#import "TradeItOrderFill.h"
#import "TradeItPriceInfo.h"
#import "TradeItCancelOrderRequest.h"

// Transactions
#import "TradeItTransactionsHistoryRequest.h"
#import "TradeItTransactionsHistoryResult.h"
#import "TradeItTransaction.h"

#import "TradeItBrokerListResult.h"

// EMS API Util classes
#import "TradeItTypeDefs.h"
#import "TradeItUserAgentProvider.h"

#endif
