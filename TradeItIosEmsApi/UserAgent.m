#import "UserAgent.h"
#include <UIKit/UIKit.h>
#include <sys/sysctl.h>

#ifdef CARTHAGE
    #import <TradeItIosTicketSDK2Carthage/TradeItIosTicketSDK2Carthage-Swift.h>
#else
    #import <TradeItIosTicketSDK2/TradeItIosTicketSDK2-Swift.h>
#endif

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
    
    NSDictionary<NSString *, id> * bundleProviderSDK2 = [[TradeItBundleProvider provide] infoDictionary];
    
    NSString *sdkName = [bundleProviderSDK2 valueForKey:@"CFBundleName"];
    NSString *sdkVersion = [bundleProviderSDK2 valueForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@/%@ (%@) / %@/%@", appDescriptor,  osDescriptor, hardwareString, sdkName, sdkVersion];
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
