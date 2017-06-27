#import "TradeItParseErrorResult.h"

@implementation TradeItParseErrorResult

+ (TradeItParseErrorResult *)errorWithSystemMessage:(NSString *)systemMessage {

    TradeItParseErrorResult *errorResult = [[TradeItParseErrorResult alloc] init];

    if (errorResult) {
        errorResult.status = @"ERROR";
        errorResult.code = @100; // TODO: Move this convenience method into the swift extension so enums can be used
        errorResult.shortMessage = @"Could not complete your request";
        errorResult.systemMessage = systemMessage;
        errorResult.longMessages = @[@"Service is temporarily unavailable. Please try again."];
    }

    return errorResult;
}

@end
