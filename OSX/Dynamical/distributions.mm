//
//  distributions.c
//  Dynamical
//
//  Created by Matthew Jee on 4/19/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#include <stdio.h>
#include "distributions.h"

int DSIndexCount(int count, int resolution) {
    // 3 indices per resolution per count
    return count*resolution*3;
}

int DSVertexCount(int count, int resolution) {
    // 3 vertices per resolution per count
    return count*resolution*3;
}

void DSGenerateVertices(DSCircle *circles, int count, int resolution, float *outVertices) {
    
    // using GL_TRIANGLES
    // inefficient, should make better use of indices
    for (int i = 0; i < count; i++) {
        DSCircle *circle = &circles[i];
        GLfloat x = circle->center.x;
        GLfloat y = circle->center.y;
        GLfloat r = circle->radius;
        int base = i*resolution*3*3;
        // add one triangle for each 'res'
        for (int j = 0; j < resolution; j++) {
            GLfloat theta1 = j*1.0/resolution*M_PI*2;
            GLfloat theta2 = (j+1)*1.0/resolution*M_PI*2;
            
            outVertices[base+j*3*3] = x;
            outVertices[base+j*3*3+1] = y;
            outVertices[base+j*3*3+2] = 0;
            
            outVertices[base+j*3*3+3] = x+cosf(theta1)*r;
            outVertices[base+j*3*3+4] = y+sinf(theta1)*r;
            outVertices[base+j*3*3+5] = 0;
            
            outVertices[base+j*3*3+6] = x+cosf(theta2)*r;
            outVertices[base+j*3*3+7] = y+sinf(theta2)*r;
            outVertices[base+j*3*3+8] = 0;
        }
    }
}

int DSGenerateCircles(GLfloat *vertices, int vertexCountPerPath, int pathCount, DSCircle *outCircles) {
    GLfloat distributionBins[vertexCountPerPath][pathCount*2];
    for (int i = 0; i < vertexCountPerPath; i++) {
        for (int j = 0; j < pathCount; j++) {
            GLfloat x = vertices[j*vertexCountPerPath*6+i*6];
            GLfloat y = vertices[j*vertexCountPerPath*6+i*6+1];
            distributionBins[i][j*2] = x;
            distributionBins[i][j*2+1] = y;
        }
    }
    
    // construct distribution array
    for (int i = 0; i < vertexCountPerPath; i++) {
        // find smallest circumscribing circle:
        // find furthest points:
        // midpoint is center of circle
        // distance/2 is radius
        GLfloat largestDistance = 0;
        for (int j = 0; j < pathCount; j++) {
            GLfloat x1 = distributionBins[i][j*2];
            GLfloat y1 = distributionBins[i][j*2+1];
            for (int k = j+1; k < pathCount; k++) {
                GLfloat x2 = distributionBins[i][k*2];
                GLfloat y2 = distributionBins[i][k*2+1];
                GLfloat dx = x2-x1;
                GLfloat dy = y2-y1;
                GLfloat distance = sqrtf(dx*dx+dy*dy);
                if (distance > largestDistance) {
                    largestDistance = distance;
                    outCircles[i].center.x = (x2+x1)/2;
                    outCircles[i].center.y = (y1+y2)/2;
                    outCircles[i].radius = distance/2;
                }
            }
        }
    }
    
    return vertexCountPerPath;
}