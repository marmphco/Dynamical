/*
 mesh.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_MESH_H
#define MJ_MESH_H

#include "definitions.h"
#include "vector.h"

namespace dynam {

class Mesh {
private:
    int indexCount;
    GLuint vertexBufferObject;
    GLuint indexBufferObject;

public:
    Mesh();
    Mesh(GLfloat *vertexData,
             GLuint *indexData,
             int vertexCount,
             int indexCount,
             int vertexElements);
    ~Mesh();

    void modifyData(GLfloat *vertexData,
                    GLuint *indexData,
                    int vertexCount,
                    int indexCount,
                    int vertexElements);
    void bind(void);
    void unbind(void);
    int elementCount(void);
};

}

#endif
