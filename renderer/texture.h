/*
 texture.h
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/

#ifndef MJ_TEXTURE_H
#define MJ_TEXTURE_H

#include "definitions.h"
#include "shader.h"
#include "vector.h"

namespace dynam {

class Texture {
protected:
    GLenum target;
    GLint internalFormat;
    GLenum format;
    GLenum type;

public:
    GLuint texture;

    Texture(GLenum target, GLint internalFormat, GLenum format, GLenum type);
    ~Texture();
    void bind();
    void unbind(void);
    void bindToUnit(GLenum unit);
    void interpolation(GLint interpol);
    void wrap(GLint wrap);
    void borderColor(Vector4 color);
};

class Texture2D : public Texture {
private:
    int width;
    int height;
public:
    Texture2D(GLint internalFormat, GLenum format, GLenum type,
              int width, int height);
    template <typename dataType>
    void initData(dataType *data);
    void present(Shader *shader);
};

class Texture3D : public Texture {
private:
    int width;
    int height;
    int depth;
public:
    Texture3D(GLint internalFormat, GLenum format, GLenum type,
              int width, int height, int depth);
    template <typename dataType>
    void initData(dataType *data);
};

template <typename dataType>
void Texture2D::initData(dataType *data) {
    bind();
    glTexImage2D(target, 0, internalFormat, width, height, 0, format, type, data);
    unbind();
}

template <typename dataType>
void Texture3D::initData(dataType *data) {
    bind();
    glTexImage3D(target, 0, internalFormat, width, height, depth, 0, format, type, data);
    unbind();
}

}

#endif
