//
//  DYJavascriptEngine.h
//  Dynamical
//
//  Created by Matthew Jee on 3/17/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavascriptCore/JavascriptCore.h>
#import "../../dynamical/definitions.h"
#import "../../dynamical/dynamical.h"

using namespace dynam;

extern NSString *DYJavascriptErrorDomain;

@interface DYJavascriptEngine : NSObject
{
    JSGlobalContextRef _context;
}

+ (Integrable)integrable;

- (id)initWithSourceString:(NSString *)source error:(NSError **)error;

- (NSArray *)parameterNamesOrError:(NSError **)error;

- (void)makeCurrentEngineOrError:(NSError **)error;

- (void)prepareToEvaluateSystem:(DynamicalSystem *)system error:(NSError **)error;

@end
