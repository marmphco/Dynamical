/*
 main.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include <iostream>

#include "definitions.h"
#include "parameter.h"
#include "integrator.h"
#include "dynamical.h"

#include "shader.h"
#include "texture.h"
#include "scene.h"
#include "mesh.h"

using namespace std;
using namespace dynam;

    Shader *displayShader = new Shader();

class SystemModel : public Renderable {
public:
    SystemModel(Mesh *mesh, Shader *shader) :
        Renderable(mesh, shader, GL_LINES) {

    }
    ~SystemModel() {

    }
    void setupVertexAttributes() {
        GLint loc = shader->getAttribLocation("vPosition");
        glEnableVertexAttribArray(loc);
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 0, 0);
    };

    void setupUniforms() {

    };
};

Mesh *loadWireCube(float width, float height, float depth) {
    float vertexData[] = {
        0.0, 0.0, 0.0,
        width, 0.0, 0.0,
        width, height, 0.0,
        0.0, height, 0.0,

        0.0, 0.0, depth,
        width, 0.0, depth,
        width, height, depth,
        0.0, height, depth,
    };
    GLuint indexData[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 5, 5, 6, 6, 7, 7, 4,
        1, 5, 2, 6, 3, 7, 0, 4,
    };
    return new Mesh(vertexData, indexData, 8, 24, 3);
}

void frameBufferSizeCallback(GLFWwindow *window, int width, int height) {
    glViewport(0, 0, width, height);
    GLint loc = displayShader->getUniformLocation("aspectRatio");
    displayShader->use();
    glUniform1f(loc, 1.0*width/height);
}


int main(int, char **) {
    if (!glfwInit()) return 1;

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = glfwCreateWindow(640, 480, "Dynamical", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return 1;
    }
    glfwMakeContextCurrent(window);

    glfwSetFramebufferSizeCallback(window, frameBufferSizeCallback);

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

    /*for (double z = -5; z < 5; z++) {
        for (double y = -5; y < 5; y++) {
            for (double x = -5; x < 5; x++) {
                Vector3 p(x, y, z);
                double t = 0.0;
                for (int i = 0; i < 1000; i++) {
                    p = lorenzSystem.evaluate(p, t);
                    //cout << p.x << ", " << p.y << ", " << p.z << endl;
                    t += 0.01;
                }
            }
        }
    }*/

    Shader *shader = new Shader();
    displayShader = new Shader();
    try {
        shader->compile("shaders/basic.vsh", "shaders/basic.fsh");
        displayShader->compile("shaders/display.vsh", "shaders/display.fsh");
    } catch(exception &e) {
        cout << e.what() << endl;
        glfwTerminate();
        return 0;
    }
    displayShader->dumpAttributes();
    shader->dumpAttributes();

    Texture2D *displayTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, 480, 480);
    displayTexture->interpolation(GL_LINEAR);
    displayTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
    displayTexture->initData((float *)0);

    Framebuffer *framebuffer = new Framebuffer(480, 480);
    framebuffer->addRenderTarget(displayTexture, GL_COLOR_ATTACHMENT0);
    framebuffer->addRenderTarget(GL_DEPTH_COMPONENT, GL_DEPTH_ATTACHMENT);
    framebuffer->backgroundColor = Vector4(0.0, 0.0, 0.0, 0.0);
    framebuffer->clear(GL_COLOR_BUFFER_BIT);

    Mesh *mesh = loadWireCube(1.0, 1.0, 1.0);

    SystemModel *model = new SystemModel(mesh, shader);
    model->center = Vector3(0.5, 0.5, 0.5);
    model->init();

    Scene *scene = new Scene(framebuffer);
    scene->camera.perspective(-1.0f, 1.0f, -1.0f, 1.0f, 8.0f, 20.0f);
    scene->camera.position = Vector3(0.0, 0.0, 10.0);
    scene->add(model);

        int width, height;
        glfwGetFramebufferSize(window, &width, &height);
        glViewport(0, 0, width, height);
        GLint loc = displayShader->getUniformLocation("aspectRatio");
        displayShader->use();
        glUniform1f(loc, 1.0*width/height);
        
    while (!glfwWindowShouldClose(window)) {
        glfwWaitEvents();
        model->rotateGlobal(0.1, Vector3(1.0, 1.0, 0.0));


        scene->render();

        int width, height;
        glfwGetFramebufferSize(window, &width, &height);
        glViewport(0, 0, width, height);
        displayTexture->present(displayShader);

        glfwSwapBuffers(window);
    }

    glfwTerminate();
    return 0;
}
