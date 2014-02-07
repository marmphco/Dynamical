/*
 main.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include <iostream>
#include <cassert>

#include "definitions.h"
#include "parameter.h"
#include "integrator.h"
#include "dynamical.h"

#include "renderer/shader.h"
#include "renderer/texture.h"
#include "renderer/scene.h"
#include "renderer/mesh.h"

using namespace std;
using namespace dynam;

DynamicalSystem *lorenzSystem;
Shader *displayShader;


enum LorenzParameter {
    LORENZ_SIGMA,
    LORENZ_RHO,
    LORENZ_BETA
};

enum RosslerParameter {
    ROSSLER_A,
    ROSSLER_B,
    ROSSLER_C
};

Vector3 lorenz(ParameterList &p, Vector3 x, double t);
Vector3 rossler(ParameterList &p, Vector3 x, double t);

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

class SystemModel : public Renderable {
public:
    SystemModel(Mesh *mesh, Shader *shader) :
        Renderable(mesh, shader, GL_LINE_STRIP) {

    }
    ~SystemModel() {

    }
    void setupVertexAttributes() {
        GLint loc = shader->getAttribLocation("vPosition");
        glEnableVertexAttribArray(loc);
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
        loc = shader->getAttribLocation("vVelocity");
        glEnableVertexAttribArray(loc);
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
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

void cursorPosCallback(GLFWwindow *window, double x, double y) {
    lorenzSystem->parameter(LORENZ_BETA).setValue(x/640.0*20.0);
    lorenzSystem->parameter(LORENZ_RHO).setValue(y/480.0*56.0);
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
    glfwSetCursorPosCallback(window, cursorPosCallback);

    RK4Integrator integrator(0.01);

    lorenzSystem = new DynamicalSystem(lorenz, integrator, 3);

    Parameter &sigma = lorenzSystem->parameter(LORENZ_SIGMA);
    Parameter &rho = lorenzSystem->parameter(LORENZ_RHO);
    Parameter &beta = lorenzSystem->parameter(LORENZ_BETA);
    
    sigma.name = "sigma";
    rho.name = "rho";
    beta.name = "beta";
    sigma.setValue(10.0);
    rho.setValue(28.0);
    beta.setValue(8.0/3.0);

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

    Texture2D *displayTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, 480, 480);
    displayTexture->interpolation(GL_LINEAR);
    displayTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
    displayTexture->initData((float *)0);

    Framebuffer *framebuffer = new Framebuffer(480, 480);
    framebuffer->addRenderTarget(displayTexture, GL_COLOR_ATTACHMENT0);
    framebuffer->addRenderTarget(GL_DEPTH_COMPONENT, GL_DEPTH_ATTACHMENT);
    framebuffer->backgroundColor = Vector4(0.0, 0.0, 0.0, 0.0);
    framebuffer->clear(GL_COLOR_BUFFER_BIT);

    GLfloat vertices[384000];
    GLuint indices[64000];
    Mesh *mesh = new Mesh((GLfloat *)vertices, indices, 128000, 64000, 3);

    SystemModel *model = new SystemModel(mesh, shader);
    model->scale = Vector3(0.01, 0.01, 0.01);
    model->center = Vector3(00, 20, 20);
    model->init();

    Scene *scene = new Scene(framebuffer);
    scene->camera.perspective(-1.0f, 1.0f, -1.0f, 1.0f, 8.0f, 20.0f);
    scene->camera.position = Vector3(0.0, 0.0, 10.0);
    scene->add(model);

    int width, height;
    glfwGetFramebufferSize(window, &width, &height);
    GLint loc = displayShader->getUniformLocation("aspectRatio");
    displayShader->use();
    glUniform1f(loc, 1.0*width/height);

    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        model->rotateGlobal(2, Vector3(1.0, 1.0, 0.0));

        int idx = 0;
        for (double z = -2; z < 2; z++) {
            for (double y = -2; y < 2; y++) {
                for (double x = -2; x < 2; x++) {
                    Vector3 p(x, y, z);
                    double t = 0.0;
                    for (int i = 0; i < 1000; i++) {
                        Vector3 op = p;
                        p = lorenzSystem->evaluate(p, t);

                        vertices[idx*6] = (GLfloat)p.x;
                        vertices[idx*6+1] = (GLfloat)p.y;
                        vertices[idx*6+2] = (GLfloat)p.z;

                        vertices[idx*6+3] = (GLfloat)p.x-op.x;
                        vertices[idx*6+4] = (GLfloat)p.y-op.y;
                        vertices[idx*6+5] = (GLfloat)p.z-op.z;

                        indices[idx] = idx;
                        idx++;
                        t += 0.01;
                    }
                }
            }
        }
        mesh->modifyData((GLfloat *)vertices, indices, 128000, 64000, 3);

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
