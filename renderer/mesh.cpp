/*
 mesh.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "mesh.h"

namespace dynam {

Mesh::~Mesh() {
    glDeleteBuffers(2, &vertexBufferObject);
}

Mesh::Mesh() {
    glGenBuffers(2, &vertexBufferObject);
    //empty geometry object
}

Mesh::Mesh(GLfloat *vertexData,
           GLuint *indexData,
           int vertexCount,
           int indexCounti,
           int vertexElements) {
    indexCount = indexCounti;
    // The vertex buffer and index buffer are adjacent
    glGenBuffers(2, &vertexBufferObject);
    modifyData(vertexData, indexData, vertexCount, indexCount, vertexElements);
}

void Mesh::modifyData(GLfloat *vertexData,
                      GLuint *indexData,
                      int vertexCount,
                      int indexCounti,
                      int vertexElements) {

    indexCount = indexCounti;
    int vertexSize = vertexElements*vertexCount*sizeof(GLfloat);
    int indexSize = indexCount*sizeof(GLuint);

    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferObject);
    glBufferData(GL_ARRAY_BUFFER, vertexSize, vertexData, GL_DYNAMIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexSize, indexData, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void Mesh::bind(void) {
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferObject);
}

void Mesh::unbind(void) {
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

int Mesh::elementCount(void) {
    return indexCount;
}

}
