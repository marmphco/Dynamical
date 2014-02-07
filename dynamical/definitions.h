/*
 definitions.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef DYNAM_DEFINITIONS_H
#define DYNAM_DEFINITIONS_H
 
#include <vector>
#include <string>
#include "../renderer/vector.h"
#include "parameter.h"

namespace dynam {

typedef std::vector<Parameter> ParameterList;
typedef Vector3 (*Integrable)(ParameterList &p, Vector3 x, double t);
    
}

#endif
