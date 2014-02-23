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

#include "transform.h"
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
    Transform transform;

    int visible;

    void (*setupVertexAttributes)(Renderable *);
    void (*setupUniforms)(Renderable *);

    Renderable(Mesh *, Shader *, GLenum drawType);
    virtual ~Renderable();
    void init();
    void render(void);
};

}

#endif
