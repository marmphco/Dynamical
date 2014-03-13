//
//  DYDefinitions.cc
//  Dynamical
//
//  Created by Matthew Jee on 3/12/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYDefinitions.h"

void setupVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
    loc = object->shader->getAttribLocation("vVelocity");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
};

Mesh *loadCube(float width, float height, float depth) {
    float vertexData[] = {
        0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
        width, 0.0, 0.0, 1.0, 1.0, 1.0,
        width, height, 0.0, 1.0, 1.0, 1.0,
        0.0, height, 0.0, 1.0, 1.0, 1.0,
        
        0.0, 0.0, depth, 1.0, 1.0, 1.0,
        width, 0.0, depth, 1.0, 1.0, 1.0,
        width, height, depth, 1.0, 1.0, 1.0,
        0.0, height, depth, 1.0, 1.0, 1.0
    };
    GLuint indexData[] = {
        0, 3, 1,
        3, 2, 1,
        1, 2, 5,
        2, 6, 5,
        0, 7, 3,
        0, 4, 7,
        3, 7, 2,
        7, 6, 2,
        4, 5, 7,
        7, 5, 6,
        0, 1, 4,
        1, 5, 4,
    };
    return new Mesh(vertexData, indexData, 16, 36, 3);
}

Vector3 lorenz(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);
    
    double rho = p[LORENZ_RHO].value();
    double sigma = p[LORENZ_SIGMA].value();
    double beta = p[LORENZ_BETA].value();
    
    return Vector3(
        sigma*(x.y-x.x),
        x.x*(rho-x.z)-x.y,
        x.x*x.y-beta*x.z
    );
}

Vector3 rossler(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);
    
    double a = p[ROSSLER_A].value();
    double b = p[ROSSLER_B].value();
    double c = p[ROSSLER_C].value();
    
    return Vector3(
        -x.y-x.z,
        x.x+a*x.y,
        b+x.z*(x.x-c)
    );
}


static JSGlobalContextRef _jsContext = NULL;
static JSObjectRef _jsSystem;
static JSValueRef _jsArgs[4];

Vector3 _dyfunction(ParameterList &p, Vector3 x, double) {
    
    _jsArgs[0] = JSObjectMakeArray(_jsContext, 0, NULL, NULL);
    _jsArgs[1] = JSValueMakeNumber(_jsContext, x.x);
    _jsArgs[2] = JSValueMakeNumber(_jsContext, x.y);
    _jsArgs[3] = JSValueMakeNumber(_jsContext, x.z);

    for (unsigned i = 0; i < p.size(); ++i) {
        JSValueRef value = JSValueMakeNumber(_jsContext, p[i].value());
        JSObjectSetPropertyAtIndex(_jsContext, (JSObjectRef)_jsArgs[0], i, value, NULL);
    }
    
    JSObjectRef output = (JSObjectRef)JSObjectCallAsFunction(_jsContext, _jsSystem, NULL, 4, _jsArgs, NULL);
    JSValueRef xValue = JSObjectGetPropertyAtIndex(_jsContext, output, 0, NULL);
    JSValueRef yValue = JSObjectGetPropertyAtIndex(_jsContext, output, 1, NULL);
    JSValueRef zValue = JSObjectGetPropertyAtIndex(_jsContext, output, 2, NULL);
    
    return Vector3(
        JSValueToNumber(_jsContext, xValue, NULL),
        JSValueToNumber(_jsContext, yValue, NULL),
        JSValueToNumber(_jsContext, zValue, NULL)
    );
}

JSGlobalContextRef DYJavascriptCreateContext(const char *src) {
    JSGlobalContextRef context = JSGlobalContextCreate(NULL);
    JSStringRef jsSrc = JSStringCreateWithUTF8CString(src);
    JSValueRef exception = NULL;
    JSEvaluateScript(context, jsSrc, NULL, NULL, 0, &exception);
    JSStringRelease(jsSrc);
    
    JSObjectRef rootObject = JSContextGetGlobalObject(context);
    JSStringRef evolutionName = JSStringCreateWithUTF8CString("evolution");
    JSValueRef system = JSObjectGetProperty(context, rootObject, evolutionName, NULL);
    JSValueProtect(context, system);
    JSStringRelease(evolutionName);
    
    JSStringRef parameterName = JSStringCreateWithUTF8CString("parameters");
    JSValueProtect(context, JSObjectGetProperty(context, rootObject, parameterName, NULL));
    JSStringRelease(parameterName);
    return context;
}

NSArray *DYJavascriptGetParameters(JSGlobalContextRef context)
{
    JSObjectRef rootObject = JSContextGetGlobalObject(context);

    JSStringRef parameterName = JSStringCreateWithUTF8CString("parameters");
    JSObjectRef parameters = (JSObjectRef)JSObjectGetProperty(context, rootObject, parameterName, NULL);
    JSStringRelease(parameterName);
    
    JSStringRef lengthName = JSStringCreateWithUTF8CString("length");
    JSValueRef lengthValue = JSObjectGetProperty(context, parameters, lengthName, NULL);
    unsigned length = (unsigned)JSValueToNumber(context, lengthValue, NULL);
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    char buffer[4096];
    for (int i = 0; i < length; ++i) {
        JSValueRef paramNameValue = JSObjectGetPropertyAtIndex(context, parameters, i, NULL);
        JSStringRef paramNameString = JSValueToStringCopy(context, paramNameValue, NULL);
        JSStringGetUTF8CString(paramNameString, buffer, 4096);
        [output addObject:[NSString stringWithUTF8String:buffer]];
    }
    
    return output;
}

void DYJavascriptSetCurrentContext(JSGlobalContextRef context) {
    _jsContext = context;
    JSObjectRef rootObject = JSContextGetGlobalObject(_jsContext);
    JSStringRef name = JSStringCreateWithUTF8CString("evolution");
    _jsSystem = (JSObjectRef)JSObjectGetProperty(_jsContext, rootObject, name, NULL);
    JSStringRelease(name);
}

Integrable DYJavascriptGetIntegrable(void) {
    return _dyfunction;
}

