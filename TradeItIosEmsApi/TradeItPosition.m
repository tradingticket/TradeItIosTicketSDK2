#import "TradeItPosition.h"

@implementation TradeItPosition

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"positionDescription": @"description"
                                                                  }];
}
@end
