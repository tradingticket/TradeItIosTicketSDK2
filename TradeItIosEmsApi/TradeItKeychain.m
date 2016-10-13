//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//
// Created by Frank Kim on 1/3/11.
//

#import "TradeItKeychain.h"
#import <Security/Security.h>

@implementation TradeItKeychain

+ (void)saveString:(NSString *)inputString forKey:(NSString	*)account {
	NSAssert(account != nil, @"Invalid account");
	NSAssert(inputString != nil, @"Invalid string");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:account forKey:(__bridge id)kSecAttrAccount];
	[query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	
	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
	if (error == errSecSuccess) {
		// do update
		NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] 
																	  forKey:(__bridge id)kSecValueData];
		
		error = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
		NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %i", (int)error);
	} else if (error == errSecItemNotFound) {
		// do add
		[query setObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
		
		error = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
		NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %i", (int)error);
	} else {
		NSAssert1(NO, @"SecItemCopyMatching failed: %i", (int)error);
	}
}

+ (NSString *)getStringForKey:(NSString *)account {
	NSAssert(account != nil, @"Invalid account");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:account forKey:(__bridge id)kSecAttrAccount];
	[query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

	NSData * dataFromKeychain = nil;

	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, (void *)&dataFromKeychain);
	
	NSString *stringToReturn = nil;
	if (error == errSecSuccess) {
        stringToReturn = [[NSString alloc] initWithData:dataFromKeychain encoding:NSUTF8StringEncoding];
	}
	
	return stringToReturn;
}

+ (void)deleteStringForKey:(NSString *)account {
	NSAssert(account != nil, @"Invalid account");

	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:account forKey:(__bridge id)kSecAttrAccount];
		
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	if (status != errSecSuccess) {
		NSLog(@"SecItemDelete failed: %i", (int)status);
	}
}

@end

























