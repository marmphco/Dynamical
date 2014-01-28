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

// test integrables in here for now
Vector3 lorenz(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);

    double rho = p[LORENZ_RHO].value();
    double sigma = p[LORENZ_SIGMA].value();
    double beta = p[LORENZ_BETA].value();

    return Vector3(
        sigma*(x.y-x.x),
        x.x*(rho-x.z)-x.y,
        x.x*x.y-beta*x.z
    );
}

Vector3 rossler(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);

    double a = p[ROSSLER_A].value();
    double b = p[ROSSLER_B].value();
    double c = p[ROSSLER_C].value();

    return Vector3(
        -x.y-x.z,
        x.x+a*x.y,
        b+x.z*(x.x-c)
    );
}

}
