/*
 renderable.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "renderable.h"

namespace dynam {

Renderable::Renderable(Mesh *meshi, Shader *shaderi, GLenum drawTypei) :
    mesh(meshi),
    shader(shaderi),
    drawType(drawTypei),
    polygonMode(GL_FILL),
    visible(true),
    setupVertexAttributes(NULL),
    setupUniforms(NULL) {
}

Renderable::~Renderable() {
    glDeleteVertexArrays(1, &vertexArrayObject);
}

void Renderable::init() {
    glGenVertexArrays(1, &vertexArrayObject);
    glBindVertexArray(vertexArrayObject);
    mesh->bind();
    if (setupVertexAttributes) {
        setupVertexAttributes(this);
    }
    glBindVertexArray(0);
    mesh->unbind();
}

void Renderable::render(void) {
    if (!visible) return;
    shader->use();
    if (setupUniforms) {
        setupUniforms(this);
    }
    shader->setUniformMatrix4fv("modelMatrix", 1, GL_FALSE, transform.matrix().data);
    shader->setUniformMatrix4fv("inverseModelMatrix", 1, GL_FALSE, transform.inverseMatrix().data);
    glPolygonMode(GL_FRONT_AND_BACK, polygonMode);
    glBindVertexArray(vertexArrayObject);
    mesh->bind();
    glDrawElements(drawType, mesh->elementCount(), GL_UNSIGNED_INT, 0);
    mesh->unbind();
    glBindVertexArray(0);
}

}
