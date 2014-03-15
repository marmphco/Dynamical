/*
 integrator.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef INTEGRATOR_H
#define INTEGRATOR_H

#include "definitions.h"

namespace dynam {

class Integrator {
protected:
    double h;
    double half_h;
public:
    Integrator(double step);
    virtual Vector3 evaluate(Integrable f, ParameterList &p, Vector3 x, double t) = 0;
    virtual ~Integrator();

    double step(void);
    void setStep(double newStep);
};

class RK4Integrator : public Integrator {
public:
    RK4Integrator(double step);
    virtual ~RK4Integrator();
    virtual Vector3 evaluate(Integrable f, ParameterList &p, Vector3 x, double t);
};

class EulerIntegrator : public Integrator {
public:
    EulerIntegrator(double step);
    virtual ~EulerIntegrator();
    virtual Vector3 evaluate(Integrable f, ParameterList &p, Vector3 x, double t);
};

}

#endif
