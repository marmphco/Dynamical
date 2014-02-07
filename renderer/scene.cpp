/*
 scene.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#include "scene.h"

namespace dynam {

    Scene::Scene(Framebuffer *framebuffer) :
        framebuffer(framebuffer),
        clearEnabled(true), //must be manually disabled
        blendEnabled(false),
        sFactorRGB(GL_SRC_ALPHA),
        dFactorRGB(GL_ONE_MINUS_SRC_ALPHA),
        sFactorA(GL_SRC_ALPHA),
        dFactorA(GL_ONE_MINUS_SRC_ALPHA),
        blendEquationRGB(GL_FUNC_ADD),
        blendEquationA(GL_FUNC_ADD) {
    }

    Scene::~Scene() {
        // delete all objects?
    }

    void Scene::add(Renderable *object) {
        renderables.push_back(object);
    }

    void Scene::remove(Renderable *) {
        // i guess we got to search for this guy
        //or give it an id field
    }

    void Scene::render() {
        if (clearEnabled) {
            framebuffer->clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        }
        framebuffer->bind();
        glViewport(0, 0, framebuffer->width(), framebuffer->height());
        if (blendEnabled) {
            glEnable(GL_BLEND);
            glBlendEquationSeparate(blendEquationRGB, blendEquationA);
            glBlendFuncSeparate(sFactorRGB, dFactorRGB, sFactorA, dFactorA);
        } else {
            glDisable(GL_BLEND);
        }

        GLfloat *projectionMatrix = camera.projectionMatrix().data;
        GLfloat *viewMatrix = camera.viewMatrix().data;
        GLfloat *inverseViewMatrix = camera.inverseViewMatrix().data;
        // render objects
        for (unsigned int i = 0; i != renderables.size(); ++i) {
            Renderable &object = *renderables[i];
            Shader &shader = *object.shader;
            shader.use();
            // matrix uniforms
            shader.setUniformMatrix4fv("projectionMatrix", 1, GL_FALSE, projectionMatrix);
            shader.setUniformMatrix4fv("viewMatrix", 1, GL_FALSE, viewMatrix);
            shader.setUniformMatrix4fv("inverseViewMatrix", 1, GL_FALSE, inverseViewMatrix);
            object.render();
        }
        framebuffer->unbind();
    }
}

