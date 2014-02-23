/*
 camera.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "camera.h"

namespace dynam {

Camera::Camera() : zoom(1.0) {}

void Camera::perspective(float left,
                         float right,
                         float bottom,
                         float top,
                         float near,
                         float far) {
    _left = left;
    _right = right;
    _bottom = bottom;
    _top = top;
    _near = near;
    _far = far;
}
void Camera::orthographic(float left,
                          float right,
                          float bottom,
                          float top,
                          float near,
                          float far) {
    _left = left;
    _right = right;
    _bottom = bottom;
    _top = top;
    _near = near;
    _far = far;
    _projectionMatrix.ortho(left,
                            right,
                            bottom,
                            top,
                            near,
                            far);
}

Matrix4 &Camera::projectionMatrix() {
    _projectionMatrix.frustum(_left,
                              _right,
                              _bottom,
                              _top,
                              _near*zoom,
                              _far);
    return _projectionMatrix;
}


Matrix4 Camera::viewMatrix() {
    Matrix4 viewMatrix;
    viewMatrix.translate(-transform.position.x, -transform.position.y, -transform.position.z);
    Matrix4 temp = transform.rotation;
    temp.transpose();
    viewMatrix = temp * viewMatrix;
    return viewMatrix;
}

Matrix4 Camera::inverseViewMatrix() {
  Matrix4 inverseViewMatrix;
    inverseViewMatrix.identity();
    inverseViewMatrix = transform.rotation;
    inverseViewMatrix.translate(transform.position.x, transform.position.y, transform.position.z);
    return inverseViewMatrix;
}

}
