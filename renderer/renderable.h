/*
 renderable.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
 
 Shader Requirements:
 modelMatrix
 inverseModelMatrix
*/

#ifndef MJ_RENDERABLE_H
#define MJ_RENDERABLE_H

#include "definitions.h"
#include "matrix.h"
#include "shader.h"
#include "mesh.h"

namespace dynam {

class Renderable {
friend class Scene;
private:
    GLuint vertexArrayObject;

public:
    Mesh *mesh;
    Shader *shader;
    GLenum drawType;
    GLenum polygonMode;

    Matrix4 rotation;
    Vector3 center;
    Vector3 scale;
    Vector3 position;

    int visible;

    void (*setupVertexAttributes)(Renderable *);
    void (*setupUniforms)(Renderable *);

    Renderable(Mesh *, Shader *, GLenum drawType);
    virtual ~Renderable();
    void init();
    void render(void);

    void resetRotation();
    void rotateGlobal(float angle, Vector3 axis);
    void rotateLocal(float angle, Vector3 axis);
    void translateGlobal(float amount, Vector3 axis);
    void translateLocal(float amount, Vector3 axis);
    void scaleUniform(float s);
    void addScaleUniform(float s);

    Matrix4 modelMatrix();
    Matrix4 inverseModelMatrix();
};

}

#endif
