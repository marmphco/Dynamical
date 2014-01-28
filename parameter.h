/*
 parameter.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef DYNAM_PARAMETER_H
#define DYNAM_PARAMETER_H

#include <string>

namespace dynam {

class Parameter {
private:
    double _value;

public:
    std::string name;

    Parameter(void);
    Parameter(std::string name);
    Parameter(double initialValue);
    Parameter(std::string name, double initialValue);

    void setValue(double newValue);
    double value(void);

    friend std::ostream &operator<<(std::ostream&, dynam::Parameter&);
};


}

#endif
