#import "TradeItPosition.h"

@implementation TradeItPosition

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"positionDescription": @"description",
                                                                  @"currencyCode": @"currency"
                                                                  }];
}
@end
