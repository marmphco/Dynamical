/*
 framebuffer.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_FRAMEBUFFER_H
#define MJ_FRAMEBUFFER_H

#include "definitions.h"
#include "vector.h"
#include "texture.h"
#include <map>

namespace dynam {

class Framebuffer {
private:
    std::map<GLenum, GLuint> renderbuffers;
    GLuint framebuffer;
    int _width;
    int _height;

public:
    Vector4 backgroundColor;

    Framebuffer(float width, float height);
    ~Framebuffer();

    GLenum completeness();
    void addRenderTarget(GLenum format, GLenum attachment);
    void addRenderTarget(Texture2D *, GLenum attachment);
    void setDrawBuffers(int count, GLenum *buffers);

    void bind();
    void unbind();

    int width();
    int height();

    void clear(GLbitfield mask);
};

}

#endif
