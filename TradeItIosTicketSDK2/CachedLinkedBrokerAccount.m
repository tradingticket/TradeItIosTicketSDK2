#import "CachedLinkedBrokerAccount.h"

@implementation CachedLinkedBrokerAccount

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    NSArray *optionalProperties = @[@"userCanDisableMargin", @"balanceLastUpdated", @"balance", @"fxBalance"];
    return [optionalProperties containsObject:propertyName];
}

@end
