/*
 main.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include <iostream>

#include "GLFW/glfw3.h"
#include "parameter.h"
#include "integrator.h"
#include "dynamical.h"
#include "definitions.h"

using namespace std;
using namespace dynam;

int main(int, char **) {
    /*if (!glfwInit()) return 1;

    GLFWwindow *window = glfwCreateWindow(640, 480, "Dynamical", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return 1;
    }*/
    RK4Integrator integrator(0.01);

    DynamicalSystem lorenzSystem = DynamicalSystem(lorenz, integrator, 3);

    Parameter &sigma = lorenzSystem.parameter(LORENZ_SIGMA);
    Parameter &rho = lorenzSystem.parameter(LORENZ_RHO);
    Parameter &beta = lorenzSystem.parameter(LORENZ_BETA);
    
    sigma.name = "sigma";
    rho.name = "rho";
    beta.name = "beta";
    sigma.setValue(10.0);
    rho.setValue(28.0);
    beta.setValue(8.0/3.0);

    for (double z = -5; z < 5; z++) {
        for (double y = -5; y < 5; y++) {
            for (double x = -5; x < 5; x++) {
                Vector3 p(x, y, z);
                double t = 0.0;
                for (int i = 0; i < 1000; i++) {
                    p = lorenzSystem.evaluate(p, t);
                    cout << p.x << ", " << p.y << ", " << p.z << endl;
                    t += 0.01;
                }
            }
        }
    }

   /* while (!glfwWindowShouldClose(window)) {
        glfwWaitEvents();
        glfwSwapBuffers(window);
    }

    glfwTerminate();*/
    return 0;
}
