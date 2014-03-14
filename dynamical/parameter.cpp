/*
 parameter.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include <iostream>

#include "parameter.h"

namespace dynam {

Parameter::Parameter() :
    _value(0.0), _minValue(0.0), _maxValue(0.0), name("unnamed") {}
Parameter::Parameter(std::string name) :
    _value(0.0), _minValue(0.0), _maxValue(0.0), name(name) {}
Parameter::Parameter(double initialValue) :
    _value(initialValue), _minValue(initialValue), _maxValue(initialValue), name("unnamed") {}
Parameter::Parameter(std::string name, double initialValue) :
    _value(initialValue), _minValue(initialValue), _maxValue(initialValue), name(name) {}
Parameter::Parameter(std::string name, double initialValue, double minValue, double maxValue) :
    _value(initialValue), _minValue(minValue), _maxValue(maxValue), name(name) {}

void Parameter::setValue(double newValue) {
    _value = newValue;
    /*if (_value > _maxValue) {
        _value = _maxValue;
    }
    else if (_value < _minValue) {
        _value = _minValue;
    }*/
}

double Parameter::value() {
    return _value;
}

void Parameter::setNormalizedValue(double normValue) {
    if (normValue < 0) normValue = 0;
    if (normValue > 1) normValue = 1;
    _value = _minValue+(_maxValue-_minValue)*normValue;
}

double Parameter::normalizedValue() {
    return (_value-_minValue)/(_maxValue-_minValue);
}

void Parameter::setMinValue(double newValue) {
    /*if (newValue > _maxValue) {
        newValue = _maxValue;
    }
    _minValue = newValue;
    if (_value < _minValue) {
        _value = _minValue;
    }*/
    _minValue = newValue;
}

double Parameter::minValue() {
    return _minValue;
}

void Parameter::setMaxValue(double newValue) {
    /*if (newValue < _minValue) {
        newValue = _minValue;
    }
    _maxValue = newValue;
    if (_value > _maxValue) {
        _value = _maxValue;
    }*/
    _maxValue = newValue;
}

double Parameter::maxValue() {
    return _maxValue;
}

std::ostream &operator<<(std::ostream &os, dynam::Parameter &param) {
    os << param._value;
    return os;
}

}
