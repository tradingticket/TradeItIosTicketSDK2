#import "TradeItParseErrorResult.h"

@implementation TradeItParseErrorResult

+ (TradeItParseErrorResult *)errorWithSystemMessage:(NSString *)systemMessage {

    TradeItParseErrorResult *errorResult = [[TradeItParseErrorResult alloc] init];

    if (errorResult) {
        errorResult.status = @"ERROR";
        errorResult.code = @100; // TODO: Move this convenience method into the swift extension so enums can be used
        errorResult.shortMessage = @"Request failed";
        errorResult.systemMessage = systemMessage;
        errorResult.longMessages = @[@"Could not complete your request. Please try again."];
    }

    return errorResult;
}

@end
