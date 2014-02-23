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

    int Scene::add(Renderable *object) {
        if (freeIDs.size() > 0) {
            int id = freeIDs.back();
            freeIDs.pop_back();
            renderables[id] = object;
            return id;
        } else {
            renderables.push_back(object);
            return renderables.size()-1;
        }
    }

    void Scene::remove(int objectID) {
        renderables[objectID] = NULL;
        freeIDs.push_back(objectID);
    }

    Renderable *Scene::getObject(int objectID) {
        return renderables[objectID];
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

        Matrix4 inverseViewMatrix = camera.inverseViewMatrix();
        Matrix4 worldviewMatrix = camera.viewMatrix() * transform.matrix();
        GLfloat *projectionMatrix = camera.projectionMatrix().data;
        // render objects
        for (unsigned int i = 0; i != renderables.size(); ++i) {
            if (renderables[i] == NULL) continue;
            Renderable &object = *renderables[i];
            Shader &shader = *object.shader;
            shader.use();
            // matrix uniforms
            shader.setUniformMatrix4fv("projectionMatrix", 1, GL_FALSE, projectionMatrix);
            shader.setUniformMatrix4fv("viewMatrix", 1, GL_FALSE, worldviewMatrix.data);
            shader.setUniformMatrix4fv("inverseViewMatrix", 1, GL_FALSE, inverseViewMatrix.data);
            shader.setUniform1i("objectID", i+1);
            object.render();
        }
        framebuffer->unbind();
    }

    int Scene::pickObjectID(int x, int y) {
        framebuffer->bind();
        unsigned int id;
        glReadBuffer(GL_COLOR_ATTACHMENT1);
        glReadPixels(x, y, 1, 1, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, &id);
        glReadBuffer(GL_NONE);
        framebuffer->unbind();
        id = (id & 0xff)-1;
        if (id < renderables.size()) {
            return id;
        } else {
            return -1;
        }
    }

    Renderable *Scene::pickObject(int x, int y) {
        int id = pickObjectID(x, y);
        if (id == -1) {
            return NULL;
        } else {
            return renderables[id];
        }
    }
}

