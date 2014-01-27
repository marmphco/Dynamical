/*
 main.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "GLFW/glfw3.h"

int main(int argc, char **argv) {

    if (!glfwInit()) return 1;

    GLFWwindow *window = glfwCreateWindow(640, 480, "Dynamical", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return 1;
    }

    while (!glfwWindowShouldClose(window)) {
        glfwWaitEvents();
        glfwSwapBuffers(window);
    }

    glfwTerminate();
    return 0;
}
