#import "UserAgent.h"
#include <UIKit/UIKit.h>
#include <sys/sysctl.h>

@implementation UserAgent


+ (NSString *)getUserAgent {
    NSDictionary<NSString *, id> *bundleDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [bundleDict valueForKey:@"CFBundleName"];
    NSString *appVersion = [bundleDict valueForKey:@"CFBundleShortVersionString"];
    
    NSString * appDescriptor = [NSString stringWithFormat:@"%@/%@", appName, appVersion];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString* systemVersion = [device systemVersion];
    
    NSString * osDescriptor = [NSString stringWithFormat:@"%@ %@", @"iOS", systemVersion];
    
    NSString * hardwareString = [self getSysInfoByName:"hw.model"];
    
    NSString * version = @"TradeItIosTicketSDK2";
    return [NSString stringWithFormat:@"%@/%@ (%@) / %@", appDescriptor,  osDescriptor, hardwareString, version];
}

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

@end
