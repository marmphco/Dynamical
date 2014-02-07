/*
 definitions.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef DYNAM_DEFINITIONS_H
#define DYNAM_DEFINITIONS_H
 
#define _USE_MATH_DEFINES
#define GLFW_INCLUDE_GLCOREARB
#ifdef __APPLE__
#   include "GLFW/glfw3.h"
#else
#   include "libglew/glew.h"
#   include "GLFW/glfw3.h"
#endif

#include <vector>
#include <string>
#include "renderer/vector.h"
#include "parameter.h"

namespace dynam {

typedef std::vector<Parameter> ParameterList;
typedef Vector3 (*Integrable)(ParameterList &p, Vector3 x, double t);

// Some test integrables

enum LorenzParameter {
    LORENZ_SIGMA,
    LORENZ_RHO,
    LORENZ_BETA
};

enum RosslerParameter {
    ROSSLER_A,
    ROSSLER_B,
    ROSSLER_C
};

Vector3 lorenz(ParameterList &p, Vector3 x, double t);
Vector3 rossler(ParameterList &p, Vector3 x, double t);
    
}

#endif
