//
//  JSONModelError.m
//
//  @version 1.0.2
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012-2014 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "TIEMSJSONModelError.h"

NSString* const TIEMSJSONModelErrorDomain = @"JSONModelErrorDomain";
NSString* const TIEMSkJSONModelMissingKeys = @"kJSONModelMissingKeys";
NSString* const TIEMSkJSONModelTypeMismatch = @"kJSONModelTypeMismatch";
NSString* const TIEMSkJSONModelKeyPath = @"kJSONModelKeyPath";

@implementation TIEMSJSONModelError

+(id)errorInvalidDataWithMessage:(NSString*)message
{
	message = [NSString stringWithFormat:@"Invalid JSON data: %@", message];
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:message}];
}

+(id)errorInvalidDataWithMissingKeys:(NSSet *)keys
{
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. Required JSON keys are missing from the input. Check the error user information.",TIEMSkJSONModelMissingKeys:[keys allObjects]}];
}

+(id)errorInvalidDataWithTypeMismatch:(NSString*)mismatchDescription
{
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. The JSON type mismatches the expected type. Check the error user information.",TIEMSkJSONModelTypeMismatch:mismatchDescription}];
}

+(id)errorBadResponse
{
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorBadResponse
                                  userInfo:@{NSLocalizedDescriptionKey:@"Bad network response. Probably the JSON URL is unreachable."}];
}

+(id)errorBadJSON
{
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorBadJSON
                                  userInfo:@{NSLocalizedDescriptionKey:@"Malformed JSON. Check the JSONModel data input."}];    
}

+(id)errorModelIsInvalid
{
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorModelIsInvalid
                                  userInfo:@{NSLocalizedDescriptionKey:@"Model does not validate. The custom validation for the input data failed."}];
}

+(id)errorInputIsNil
{
    return [TIEMSJSONModelError errorWithDomain:TIEMSJSONModelErrorDomain
                                      code:kJSONModelErrorNilInput
                                  userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
}

- (instancetype)errorByPrependingKeyPathComponent:(NSString*)component
{
    // Create a mutable  copy of the user info so that we can add to it and update it
    NSMutableDictionary* userInfo = [self.userInfo mutableCopy];

    // Create or update the key-path
    NSString* existingPath = userInfo[TIEMSkJSONModelKeyPath];
    NSString* separator = [existingPath hasPrefix:@"["] ? @"" : @".";
    NSString* updatedPath = (existingPath == nil) ? component : [component stringByAppendingFormat:@"%@%@", separator, existingPath];
    userInfo[TIEMSkJSONModelKeyPath] = updatedPath;

    // Create the new error
    return [TIEMSJSONModelError errorWithDomain:self.domain
                                      code:self.code
                                  userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

@end
