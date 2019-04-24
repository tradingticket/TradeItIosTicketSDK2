#import "TradeItTransaction.h"

@implementation TradeItTransaction

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"transactionDescription": @"description"
                                                                  }];
}
@end
