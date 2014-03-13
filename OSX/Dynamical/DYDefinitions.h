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

class ParameterHandle : public Renderable {
public:
    ParameterHandle(Mesh *mesh, Shader *shader) :
        Renderable(mesh, shader, GL_TRIANGLES) {
        transform.center = Vector3(0.5, 0.5, 0.5);
    };
};

class Seed : public Renderable {
public:
    int seedID;
    vector<int> pathIDs;
    int evolutionCount;
        
    Seed(Mesh *mesh, Shader *shader, int evolutions) :
        Renderable(mesh, shader, GL_TRIANGLES),
        pathIDs(10, 0),
        evolutionCount(evolutions){
        transform.center = Vector3(0.5, 0.5, 0.5);
    };
};

enum LorenzParameter {
    LORENZ_SIGMA,
    LORENZ_RHO,
    LORENZ_BETA
};

enum RosslerParameter {
    ROSSLER_A,
    ROSSLER_B,
    ROSSLER_C
};

void setupVertexAttributes(Renderable *object);
Mesh *loadCube(float width, float height, float depth);

Vector3 lorenz(ParameterList &p, Vector3 x, double t);
Vector3 rossler(ParameterList &p, Vector3 x, double t);

// For Javascript Custom System Definitions

JSGlobalContextRef DYJavascriptCreateContext(const char *src);
NSArray *DYJavascriptGetParameters(JSGlobalContextRef context);
void DYJavascriptSetCurrentContext(JSGlobalContextRef context);
Integrable DYJavascriptGetIntegrable(void);

#endif
