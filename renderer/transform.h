/*
 transformable.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_TRANSFORM_H
#define MJ_TRANSFORM_H

#include "vector.h"
#include "matrix.h"

namespace dynam {

class Transform {
public:
    Matrix4 rotation;
    Vector3 scale;
    Vector3 position;
    Vector3 center;

     Transform();
     ~Transform();

    void resetRotation();
    void rotateGlobal(float angle, Vector3 axis);
    void rotateLocal(float angle, Vector3 axis);
    void translateGlobal(float amount, Vector3 axis);
    void translateLocal(float amount, Vector3 axis);
    void scaleUniform(float s);
    void addScaleUniform(float s);

    void lookAt(Vector3 target, Vector3 up);

    Matrix4 matrix();
    Matrix4 inverseMatrix();
};

}

#endif
