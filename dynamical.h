/*
 dynamical.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef DYNAM_DYNAMICAL_H
#define DYNAM_DYNAMICAL_H

/* System Includes */
#include <map>
#include <vector>

/* Other Includes */
#include "parameter.h"
#include "definitions.h"
#include "integrator.h"
#include "vector.h"

namespace dynam {

class DynamicalSystem {
private:
    ParameterList parameters;
    Integrable    function;
    Integrator    &integrator;

public:
    DynamicalSystem(Integrable function, Integrator &integrator, int paramCount);
    
    Vector3 evaluate(Vector3 x, double t);
    Parameter &parameter(int id);
};

}

#endif
