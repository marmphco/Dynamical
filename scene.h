/*
 scene.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_SCENE_H
#define MJ_SCENE_H

#include <vector>
#include "definitions.h"
#include "renderable.h"
#include "camera.h"
#include "framebuffer.h"

namespace dynam {

class Scene {
private:
    
public:
    std::vector<Renderable *> renderables;

    Framebuffer *framebuffer;
    Camera camera;

    //hack to enable/disable automatic framebuffer clearing
    bool clearEnabled;
    bool blendEnabled;
    GLenum sFactorRGB;
    GLenum dFactorRGB;
    GLenum sFactorA;
    GLenum dFactorA;
    GLenum blendEquationRGB;
    GLenum blendEquationA;

    Scene(Framebuffer *);
    ~Scene();
    void add(Renderable *);
    void remove(Renderable *);
    void render();

    void eachRenderable(void (*)(Renderable *));
};

}

#endif
