/*
 integrators.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include <cassert>
#include "integrator.h"
#include "definitions.h"

namespace dynam {

Integrator::Integrator(double step) : h(step), half_h(step/2) {}
RK4Integrator::RK4Integrator(double step) : Integrator(step) {}
EulerIntegrator::EulerIntegrator(double step) : Integrator(step) {}

Vector3 EulerIntegrator::evaluate(Integrable f,
                          ParameterList &p,
                          Vector3 x,
                          double t) {
    return x+f(p, x, t)*h;
}

Vector3 RK4Integrator::evaluate(Integrable f,
                        ParameterList &p,
                        Vector3 x,
                        double t) {
    Vector3 k1 = f(p, x,             t);
    Vector3 k2 = f(p, x+k1*(half_h), t+half_h);
    Vector3 k3 = f(p, x+k2*(half_h), t+half_h);
    Vector3 k4 = f(p, x+k3*h,        t+h);

    return x+(k1+(k2+k3)*2.0+k4)*(h/6);
}

double Integrator::step() {
    return h;
}

void Integrator::setStep(double newStep) {
    h = newStep;
    half_h = h/2.0;
}

}
