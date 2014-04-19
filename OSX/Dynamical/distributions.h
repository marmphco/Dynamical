//
//  distributions.h
//  Dynamical
//
//  Created by Matthew Jee on 4/19/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#ifndef Dynamical_distributions_h
#define Dynamical_distributions_h

#include "../../renderer/vector.h"

typedef struct _DSCircle {
    dynam::Vector3 center;
    double radius;
} DSCircle;

int DSIndexCount(int count, int resolution);
int DSVertexCount(int count, int resolution);
void DSGenerateVertices(DSCircle *circles, int count, int resolution, float *outVertices);

// returns the number of circles generated
int DSGenerateCircles(GLfloat *vertices, int vertexCountPerPath, int pathCount, DSCircle *outCircles);

#endif
