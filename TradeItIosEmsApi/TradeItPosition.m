#import "TradeItPosition.h"

@implementation TradeItPosition

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"positionDescription": @"description",
                                                                  @"currencyCode": @"currency"
                                                                  }];
}

+(BOOL)propertyIsOptional:(NSString*)isProxyVoteEligible {
    if ([isProxyVoteEligible isEqualToString: @"isProxyVoteEligible"]) {
        return YES;
    }
    return NO;
}
@end
