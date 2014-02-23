/*
 transformable.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "transform.h"

namespace dynam {

Transform::Transform() :
    rotation(), scale(1.0, 1.0, 1.0), position(0.0, 0.0, 0.0), center(0.0, 0.0, 0.0) {
}

Transform::~Transform() {

}

void Transform::resetRotation() {
    rotation = Matrix4();
}

void Transform::rotateGlobal(float angle, Vector3 axis) {
    rotation.rotate(angle, axis);
}

void Transform::rotateLocal(float angle, Vector3 axis) {
    Vector3 realAxis = rotation.matrix3() * axis;
    rotation.rotate(angle, realAxis);
}

void Transform::translateGlobal(float amount, Vector3 axis) {
    position += axis*amount;
}

void Transform::translateLocal(float amount, Vector3 axis) {
    Vector3 realAxis = rotation.matrix3() * axis;
    position += realAxis*amount;
}

void Transform::scaleUniform(float s) {
    scale *= s;
}

void Transform::addScaleUniform(float s) {
    scale += s;
}

void Transform::lookAt(Vector3 target, Vector3 up) {
    //align view vector
    Vector3 dir = target-position;
    Vector3 viewVector = rotation.matrix3() * -Z_AXIS;

    float costheta = dir.normalize().dot(viewVector);
    float angle = acos(costheta > 1.0 ? 1.0 : costheta);

    Vector3 axis = viewVector.cross(dir.normalize());
    rotateGlobal(angle*180/M_PI, axis.normalize());

    //align up vector
    axis = rotation.matrix3() * Z_AXIS;
    Vector3 projection = axis*axis.dot(up);
    Vector3 realUp = (up-projection).normalize();
    Vector3 curUp = rotation.matrix3() * Y_AXIS;
    costheta = curUp.dot(realUp);
    angle = acos(costheta > 1.0 ? 1.0 : costheta);

    rotateGlobal(angle*180/M_PI, curUp.cross(realUp).normalize());
}

Matrix4 Transform::matrix() {
    Matrix4 matrix;
    matrix.translate(-center.x, -center.y, -center.z);
    matrix.scale(scale.x, scale.y, scale.z);
    matrix = rotation * matrix;
    matrix.translate(position.x, position.y, position.z);
    return matrix;
}

Matrix4 Transform::inverseMatrix() {
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
