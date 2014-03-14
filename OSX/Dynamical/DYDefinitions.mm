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

void setupPointSpriteUniforms(Renderable *object) {
    glPointSize(10.0);
}

Mesh *DYMakePointMesh(void) {
    GLfloat vertexData[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
    GLuint indexData[] = {0};
    return new Mesh(vertexData, indexData, 1, 1, 6);
}

Vector3 lorenz(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);
    
    double rho = p[0].value();
    double sigma = p[1].value();
    double beta = p[2].value();
    
    return Vector3(
        sigma*(x.y-x.x),
        x.x*(rho-x.z)-x.y,
        x.x*x.y-beta*x.z
    );
}

Vector3 rossler(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);
    
    double a = p[0].value();
    double b = p[1].value();
    double c = p[2].value();
    
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
    
    _jsArgs[1] = JSValueMakeNumber(_jsContext, x.x);
    _jsArgs[2] = JSValueMakeNumber(_jsContext, x.y);
    _jsArgs[3] = JSValueMakeNumber(_jsContext, x.z);
    
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

NSArray *DYJavascriptGetParameterNames(JSGlobalContextRef context) {
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

Integrable DYJavascriptGetIntegrable(void) {
    return _dyfunction;
}

void DYJavascriptSetCurrentContext(JSGlobalContextRef context) {
    _jsContext = context;
    JSObjectRef rootObject = JSContextGetGlobalObject(_jsContext);
    JSStringRef name = JSStringCreateWithUTF8CString("evolution");
    _jsSystem = (JSObjectRef)JSObjectGetProperty(_jsContext, rootObject, name, NULL);
    JSStringRelease(name);
}

void DYJavascriptSetupSystem(JSGlobalContextRef context, DynamicalSystem *system) {
    _jsArgs[0] = JSObjectMakeArray(context, 0, NULL, NULL);
    for (unsigned i = 0; i < system->parameterCount(); ++i) {
        JSValueRef value = JSValueMakeNumber(context, system->parameter(i).value());
        JSObjectSetPropertyAtIndex(context, (JSObjectRef)_jsArgs[0], i, value, NULL);
    }
}


