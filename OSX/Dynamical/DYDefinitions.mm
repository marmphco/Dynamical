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

void setupVertexAttributesDistribution(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), 0);
}

void setupUniformsDistribution(Renderable *object) {
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
}

void setupPointSpriteUniforms(Renderable *object) {
    glPointSize(10.0);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
}

void setupSeedUniforms(Renderable *object) {
    Seed *seed = (Seed *)object;
    if (seed->selected) {
        glPointSize(20.0);
    } else {
        glPointSize(10.0);
    }
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
}

void setupPathUniforms(Renderable *object) {
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    Path *path = (Path *)object;
    path->shader->setUniform1f("evolution", path->s);
}

void setupSimpleUniforms(Renderable *object) {
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
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

Vector3 synthetic(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 1);
    
    double a = p[0].value();
    
    return Vector3(3, (a-1)*x.y-0.1*a, 0);
}

