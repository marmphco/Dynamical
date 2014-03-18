//
//  DYJavascriptEngine.m
//  Dynamical
//
//  Created by Matthew Jee on 3/17/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYJavascriptEngine.h"
#import "../../renderer/vector.h"

NSString *DYJavascriptErrorDomain = @"DYJavascriptErrorDomain";

@implementation DYJavascriptEngine

static JSGlobalContextRef __context = NULL;
static JSObjectRef __system = NULL;
static JSValueRef __args[4];

// There is no exception handling in here, for efficiency reasons
// whether or not this is a good idea is no clear
// If the pgroam makes it past the myraid of checks in the setup functions
// it should be fine during this evaluation stage
static Vector3 __engineFunction(ParameterList &p, Vector3 x, double) {
    
    __args[1] = JSValueMakeNumber(__context, x.x);
    __args[2] = JSValueMakeNumber(__context, x.y);
    __args[3] = JSValueMakeNumber(__context, x.z);
    
    JSObjectRef output = (JSObjectRef)JSObjectCallAsFunction(__context, __system, NULL, 4, __args, NULL);
    JSValueRef xValue = JSObjectGetPropertyAtIndex(__context, output, 0, NULL);
    JSValueRef yValue = JSObjectGetPropertyAtIndex(__context, output, 1, NULL);
    JSValueRef zValue = JSObjectGetPropertyAtIndex(__context, output, 2, NULL);
    
    return Vector3(
       JSValueToNumber(__context, xValue, NULL),
       JSValueToNumber(__context, yValue, NULL),
       JSValueToNumber(__context, zValue, NULL)
    );
}

+ (Integrable)integrable
{
    return __engineFunction;
}

- (id)initWithSourceString:(NSString *)source error:(NSError **)error
{
    self = [super init];
    if (self) {
        _context = JSGlobalContextCreate(NULL);
        JSValueRef exception = NULL;
        
        JSStringRef jsSrc = JSStringCreateWithUTF8CString([source UTF8String]);
        JSEvaluateScript(_context, jsSrc, NULL, NULL, 0, &exception);
        JSStringRelease(jsSrc);
        
        if (exception) {
            if (error) *error = [self errorFromJSException:exception];
            return nil;
        }
        
        JSObjectRef rootObject = JSContextGetGlobalObject(_context);
        JSStringRef evolutionName = JSStringCreateWithUTF8CString("evolution");
        JSValueRef evolution = JSObjectGetProperty(_context, rootObject, evolutionName, &exception);
        JSStringRelease(evolutionName);
        
        if ((JSValueIsNull(_context, evolution) || JSValueIsUndefined(_context, evolution)) ) {
            if (error) {
                NSDictionary *info = @{
                    NSLocalizedFailureReasonErrorKey: @"Function 'evolution' is undefined.",
                };
                *error = [NSError errorWithDomain:DYJavascriptErrorDomain
                                             code:0
                                         userInfo:info];
            }
            return nil;
        }
        
        if (exception) {
            if (error) *error = [self errorFromJSException:exception];
            return nil;
        }
        
        // make sure that evolution is indeed a function
        JSObjectRef evolutionObject = JSValueToObject(_context, evolution, &exception);
        if (exception) {
            if (error) *error = [self errorFromJSException:exception];
            return nil;
        }
        if (!JSObjectIsFunction(_context, evolutionObject)) {
            if (error) {
                *error = [NSError errorWithDomain:DYJavascriptErrorDomain
                                             code:0
                                         userInfo:@{NSLocalizedFailureReasonErrorKey: @"'evolution' is not a function"}];
            }
            return nil;
        }
        
        JSValueProtect(_context, evolution);
        
        JSStringRef parameterName = JSStringCreateWithUTF8CString("parameters");
        JSValueRef parameters = JSObjectGetProperty(_context, rootObject, parameterName, &exception);
        JSStringRelease(parameterName);
        
        if (JSValueIsNull(_context, parameters)  || JSValueIsUndefined(_context, parameters)) {
            if (error) {
                *error = [NSError errorWithDomain:DYJavascriptErrorDomain
                                             code:0
                                         userInfo:@{NSLocalizedFailureReasonErrorKey: @"'parameters' array is undefined"}];
            }
            return nil;
        }
        
        if (exception) {
            if (error) *error = [self errorFromJSException:exception];
            return nil;
        }
        
        JSValueProtect(_context, parameters);
    }
    return self;
}

- (void)dealloc
{
    if (_context) {
        JSGlobalContextRelease(_context);
    }
}

- (NSError *)errorFromJSException:(JSValueRef)exception
{
    char messageBuffer[1024];
    
    JSStringRef propertyName = JSStringCreateWithUTF8CString("message");
    JSObjectRef errorObject = JSValueToObject(_context, exception, NULL);
    JSValueRef jsMessage = JSObjectGetProperty(_context, errorObject, propertyName, NULL);
    JSStringRef message = JSValueToStringCopy(_context, jsMessage, NULL);
    JSStringGetUTF8CString(message, messageBuffer, 1024);
    JSStringRelease(message);
    JSStringRelease(propertyName);
    
    NSDictionary *info = @{
        NSLocalizedFailureReasonErrorKey: [NSString stringWithUTF8String:messageBuffer]
    };
    NSError *error = [NSError errorWithDomain:DYJavascriptErrorDomain
                                         code:0
                                     userInfo:info];
    return error;
}

- (NSArray *)parameterNamesOrError:(NSError **)error
{
    JSObjectRef rootObject = JSContextGetGlobalObject(_context);
    JSValueRef exception = NULL;
    
    JSStringRef parameterName = JSStringCreateWithUTF8CString("parameters");
    JSObjectRef parameters = (JSObjectRef)JSObjectGetProperty(_context, rootObject, parameterName, &exception);
    JSStringRelease(parameterName);
    if (exception) {
        if (error) *error = [self errorFromJSException:exception];
        return nil;
    }
    
    JSStringRef lengthName = JSStringCreateWithUTF8CString("length");
    JSValueRef lengthValue = JSObjectGetProperty(_context, parameters, lengthName, &exception);
    if (exception) {
        if (error) *error = [self errorFromJSException:exception];
        return nil;
    }
    
    unsigned length = (unsigned)JSValueToNumber(_context, lengthValue, &exception);
    if (exception) {
        if (error) *error = [self errorFromJSException:exception];
        return nil;
    }
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    char buffer[4096];
    for (int i = 0; i < length; ++i) {
        JSValueRef paramNameValue = JSObjectGetPropertyAtIndex(_context, parameters, i, &exception);
        if (exception) {
            if (error) *error = [self errorFromJSException:exception];
            return nil;
        }
        
        JSStringRef paramNameString = JSValueToStringCopy(_context, paramNameValue, &exception);
        if (exception) {
            if (error) *error = [self errorFromJSException:exception];
            return nil;
        }
        
        JSStringGetUTF8CString(paramNameString, buffer, 4096);
        [output addObject:[NSString stringWithUTF8String:buffer]];
    }
    
    return output;
}

- (void)makeCurrentEngineOrError:(NSError **)error
{
    JSValueRef exception = NULL;

    __context = _context;
    JSObjectRef rootObject = JSContextGetGlobalObject(__context);
    JSStringRef name = JSStringCreateWithUTF8CString("evolution");
    __system = (JSObjectRef)JSObjectGetProperty(__context, rootObject, name, &exception);
    if (error && exception) {
        *error = [self errorFromJSException:exception];
    }
    
    JSStringRelease(name);
}

- (void)prepareToEvaluateSystem:(DynamicalSystem *)system error:(NSError **)error
{
    JSValueRef exception = NULL;

    __args[0] = JSObjectMakeArray(_context, 0, NULL, NULL);
    for (unsigned i = 0; i < system->parameterCount(); ++i) {
        JSValueRef value = JSValueMakeNumber(_context, system->parameter(i).value());
        JSObjectSetPropertyAtIndex(_context, (JSObjectRef)__args[0], i, value, &exception);
        if (error && exception) {
            *error = [self errorFromJSException:exception];
        }
        
    }
}

@end
