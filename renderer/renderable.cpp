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
    center(Vector3(0.0, 0.0, 0.0)),
    scale(Vector3(1.0, 1.0, 1.0)),
    position(Vector3(0.0, 0.0, 0.0)),
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
    shader->setUniformMatrix4fv("modelMatrix", 1, GL_FALSE, modelMatrix().data);
    shader->setUniformMatrix4fv("inverseModelMatrix", 1, GL_FALSE, inverseModelMatrix().data);
    glPolygonMode(GL_FRONT_AND_BACK, polygonMode);
    glBindVertexArray(vertexArrayObject);
    mesh->bind();
    glDrawElements(drawType, mesh->elementCount(), GL_UNSIGNED_INT, 0);
    mesh->unbind();
    glBindVertexArray(0);
}

void Renderable::resetRotation() {
    rotation = Matrix4();
}

void Renderable::rotateGlobal(float angle, Vector3 axis) {
    rotation.rotate(angle, axis);
}

void Renderable::rotateLocal(float angle, Vector3 axis) {
    Vector3 realAxis = rotation.matrix3() * axis;
    rotation.rotate(angle, realAxis);
}

void Renderable::translateGlobal(float amount, Vector3 axis) {
    position += axis*amount;
}

void Renderable::translateLocal(float amount, Vector3 axis) {
    Vector3 realAxis = rotation.matrix3() * axis;
    position += realAxis*amount;
    
}

void Renderable::scaleUniform(float s) {
    scale *= s;
}

void Renderable::addScaleUniform(float s) {
    scale += s;
}

Matrix4 Renderable::modelMatrix() {
    Matrix4 matrix;
    matrix.translate(-center.x, -center.y, -center.z);
    matrix.scale(scale.x, scale.y, scale.z);
    matrix = rotation * matrix;
    matrix.translate(position.x, position.y, position.z);
    return matrix;
}

Matrix4 Renderable::inverseModelMatrix() {
    Matrix4 matrix;
    matrix.translate(-position.x, -position.y, -position.z);
    Matrix4 inverseRotation = rotation;
    inverseRotation.transpose();
    matrix = matrix * inverseRotation;
    matrix.scale(1/scale.x, 1/scale.y, 1/scale.z);
    matrix.translate(center.x, center.y, center.z);
    return matrix;
}

}
