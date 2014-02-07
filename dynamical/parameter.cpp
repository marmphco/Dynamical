/*
 parameter.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include <iostream>

#include "parameter.h"

namespace dynam {

Parameter::Parameter() : _value(0.0), name("unnamed") {}
Parameter::Parameter(std::string name) : _value(0.0), name(name) {}
Parameter::Parameter(double initialValue) : _value(initialValue), name("unnamed") {}
Parameter::Parameter(std::string name, double initialValue) : _value(initialValue), name(name) {}

void Parameter::setValue(double newValue) {
    _value = newValue;
}

double Parameter::value() {
    return _value;
}

std::ostream &operator<<(std::ostream &os, dynam::Parameter &param) {
    os << param._value;
    return os;
}

}
