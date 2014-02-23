/*
 scene.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_SCENE_H
#define MJ_SCENE_H

#include <vector>
#include "transform.h"
#include "definitions.h"
#include "renderable.h"
#include "camera.h"
#include "framebuffer.h"

namespace dynam {

class Scene {
private:
    std::vector<int> freeIDs;

public:
    std::vector<Renderable *> renderables;

    Framebuffer *framebuffer;
    Camera camera;
    Transform transform;

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
    int add(Renderable *);
    void remove(int objectID);
    Renderable *getObject(int objectID);
    void render(void);

    int pickObjectID(int x, int y);
    Renderable *pickObject(int x, int y);
};

}

#endif
