/*
 vector.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_VECTOR_H
#define MJ_VECTOR_H

#include <iostream>
#include <cmath>

namespace dynam {

class Vector3 {
public:
    double x;
    double y;
    double z;
    Vector3() : x(0), y(0), z(0) {};
    Vector3(double sx, double sy, double sz) : x(sx), y(sy), z(sz) {};

    inline Vector3 operator-() const {
        return Vector3(-x, -y, -z);
    };
    inline Vector3 operator+(Vector3 that) const {
        return Vector3(x+that.x, y+that.y, z+that.z);
    };
    inline Vector3 operator-(Vector3 that) const {
        return Vector3(x-that.x, y-that.y, z-that.z);
    };
    inline Vector3 operator*(Vector3 that) const {
        return Vector3(x*that.x, y*that.y, z*that.z);
    };
    inline Vector3 operator*(double scalar) const {
        return Vector3(x*scalar, y*scalar, z*scalar);
    };
    inline Vector3 &operator+=(Vector3 that) {
        x += that.x; y += that.y; z += that.z;
        return *this;
    };
    inline Vector3 &operator+=(double that) {
        x += that; y += that; z += that;
        return *this;
    };
    inline Vector3 &operator*=(Vector3 that) {
        x *= that.x; y *= that.y; z *= that.z;
        return *this;
    };
    inline Vector3 &operator*=(double scalar) {
       x *= scalar; y *= scalar; z *= scalar;
       return *this;
    };
    inline double length() {
        return sqrtf(x*x+y*y+z*z);
    };
    inline double dot(Vector3 that) {
        return x*that.x+y*that.y+z*that.z;
    };
    inline Vector3 cross(Vector3 that) {
        return Vector3(y*that.z-z*that.y, z*that.x-x*that.z, x*that.y-y*that.x);
    };
    inline Vector3 normalized() {
        double l = length();
        return std::isfinite(1/l) ? Vector3(x/l, y/l, z/l) : *this;
    };
    inline Vector3 &normalize() {
        double linverse = 1/length();
        if (std::isfinite(linverse)) *this *= linverse;
        return *this;
    };
};

class Vector4 {
public:
    double r;
    double g;
    double b;
    double a;
    Vector4() : r(0), g(0), b(0), a(0) {};
    Vector4(double sr, double sg, double sb, double sa) :
        r(sr), g(sg), b(sb), a(sa) {};
    inline Vector4 operator-() const {
        return Vector4(-r, -g, -b, -a);
    };
    inline Vector4 operator+(Vector4 that) const {
        return Vector4(r+that.r, g+that.g, b+that.b, a+that.a);
    };
    inline Vector4 operator-(Vector4 that) const {
        return Vector4(r-that.r, g-that.g, b-that.b, a-that.a);
    };
    inline Vector4 operator*(Vector4 that) const {
        return Vector4(r*that.r, g*that.g, b*that.b, a*that.a);
    };
    inline Vector4 operator*(double scalar) const {
        return Vector4(r*scalar, g*scalar, b*scalar, a*scalar);
    };
    inline Vector4 &operator+=(Vector4 that) {
        r += that.r; g += that.g; b += that.b; a += that.a;
        return *this;
    };
    inline Vector4 &operator+=(double that) {
        r += that; g += that; b += that; a += that;
        return *this;
    };
    inline Vector4 &operator*=(Vector4 that) {
        r *= that.r; g *= that.g; b *= that.b; a *= that.a;
        return *this;
    };
    inline Vector4 &operator*=(double scalar) {
        r *= scalar; g *= scalar; b *= scalar; a *= scalar;
        return *this;
    };
    inline double length() {
        return sqrtf(r*r+g*g+b*b+a*a);
    };
    inline double dot(Vector4 that) {
        return r*that.r+g*that.g+b*that.b+a*that.a;
    };
    inline Vector4 normalized() {
        double l = length();
        return std::isfinite(1/l) ? Vector4(r/l, g/l, b/l, a/l) : *this;
    };
    inline Vector4 &normalize() {
        double linverse = 1/length();
        if (std::isfinite(linverse)) *this *= linverse;
        return *this;
    };
};

const Vector3 X_AXIS(1.0, 0.0, 0.0);
const Vector3 Y_AXIS(0.0, 1.0, 0.0);
const Vector3 Z_AXIS(0.0, 0.0, 1.0);

}

#endif
