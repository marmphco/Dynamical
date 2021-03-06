//
//  DYDefinitions.h
//  Dynamical
//
//  Created by Matthew Jee on 3/12/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#ifndef Dynamical_DYDefinitions_h
#define Dynamical_DYDefinitions_h

#import <JavaScriptCore/JavaScriptCore.h>
#include "../../renderer/shader.h"
#include "../../renderer/texture.h"
#include "../../renderer/scene.h"
#include "../../renderer/mesh.h"
#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

using namespace dynam;

typedef enum {
    DYXAxis = 0, // Red
    DYYAxis = 1, // Green
    DYZAxis = 2  // Blue
} DYAxis;

void setupVertexAttributes(Renderable *object);
void setupPointSpriteUniforms(Renderable *object);
void setupSeedUniforms(Renderable *object);
void setupPathUniforms(Renderable *object);
void setupSimpleUniforms(Renderable *object);

class Seed : public Renderable {
public:
    int seedID;
    vector<int> pathIDs;
    int evolutionCount;
    bool selected;
    
    Seed(Mesh *mesh, Shader *shader, int evolutions) :
        Renderable(mesh, shader, GL_POINTS),
        pathIDs(evolutions, 0),
        evolutionCount(evolutions),
        selected(false) {
        this->setupVertexAttributes = setupVertexAttributes;
        this->setupUniforms = setupSeedUniforms;
    };
};

class Path : public Renderable {
public:
    float s;
    
    Path(Mesh *mesh, Shader *shader, float s) :
        Renderable(mesh, shader, GL_LINE_STRIP),
        s(s) {
        this->setupVertexAttributes = setupVertexAttributes;
        this->setupUniforms = setupPathUniforms;
    };
};

Mesh *DYMakePointMesh(void);

Vector3 lorenz(ParameterList &p, Vector3 x, double t);
Vector3 rossler(ParameterList &p, Vector3 x, double t);
/*
// For Javascript Custom System Definitions

// Create a new context for evaluating an evolution function
JSGlobalContextRef DYJavascriptCreateContext(const char *src);

// Get the parameters specified by the given context
NSArray *DYJavascriptGetParameterNames(JSGlobalContextRef context);

// Returns the shared Integrable
Integrable DYJavascriptGetIntegrable(void);

// Sets the given context to be used for evaluation in the 
// shared integrable
void DYJavascriptSetCurrentContext(JSGlobalContextRef context);

// This exists purely for optimization purposes
// Sets the parameter array argument so that it does not
// need to happen every evaluation.
void DYJavascriptSetupSystem(JSGlobalContextRef context, DynamicalSystem *system);
*/
#endif
