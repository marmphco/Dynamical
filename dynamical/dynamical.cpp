/*
 dynamical.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "dynamical.h"

namespace dynam {

DynamicalSystem::DynamicalSystem(Integrable function, Integrator &integrator, int paramCount) :
    parameters(ParameterList(paramCount, Parameter())),
    function(function),
    integrator(integrator) {}

Parameter &DynamicalSystem::parameter(int id) {
    // check for id in bounds
    return parameters[id];
}

Vector3 DynamicalSystem::evaluate(Vector3 x, double t) {
    return integrator.evaluate(function, parameters, x, t);
}

}
