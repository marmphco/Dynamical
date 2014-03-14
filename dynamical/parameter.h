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
    double _minValue;
    double _maxValue;

public:
    std::string name;

    Parameter(void);
    Parameter(std::string name);
    Parameter(double initialValue);
    Parameter(std::string name, double initialValue);
    Parameter(std::string name, double initialValue, double minValue, double maxValue);

    void setValue(double newValue);
    double value(void);

    void setNormalizedValue(double normValue);
    double normalizedValue();

    void setMinValue(double newValue);
    double minValue(void);

    void setMaxValue(double newValue);
    double maxValue(void);

    friend std::ostream &operator<<(std::ostream&, dynam::Parameter&);
};


}

#endif
