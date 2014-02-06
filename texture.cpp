/*
 framebuffer.cpp
 Dynamical
 Matthew Jee
 mcjee@ucsc.edu
*/
 
#include "texture.h"

namespace dynam {

Texture::Texture(GLenum target, GLint internalFormat, GLenum format, GLenum type) :
    target(target), internalFormat(internalFormat), format(format), type(type) {
    glGenTextures(1, &texture);
    bind();
    // arbitrary defaults
    glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_BORDER);
    glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
    unbind();
}

Texture::~Texture() {
    glDeleteTextures(1, &texture);
}

void Texture::bind(void) {
    glBindTexture(target, texture);
}

void Texture::unbind(void) {
    glBindTexture(target, 0);
}

void Texture::bindToUnit(GLenum unit) {
    glActiveTexture(unit);
    glBindTexture(target, texture);
}

void Texture::interpolation(GLint interpol) {
    bind();
    glTexParameteri(target, GL_TEXTURE_MIN_FILTER, interpol);
    glTexParameteri(target, GL_TEXTURE_MAG_FILTER, interpol);
    unbind();
}

void Texture::wrap(GLint wrap) {
    bind();
    glTexParameteri(target, GL_TEXTURE_WRAP_S, wrap);
    glTexParameteri(target, GL_TEXTURE_WRAP_R, wrap);
    glTexParameteri(target, GL_TEXTURE_WRAP_T, wrap);
    unbind();
}

void Texture::borderColor(Vector4 color) {
    bind();
    glTexParameterfv(target, GL_TEXTURE_BORDER_COLOR, (const GLfloat *)&color);
    unbind();
}

Texture2D::Texture2D(GLint internalFormat, GLenum format, GLenum type,
                     int width, int height) :
    Texture(GL_TEXTURE_2D, internalFormat, format, type),
    width(width), height(height) {

}

void Texture2D::present(Shader *shader) {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBlendFunc(GL_ONE, GL_ZERO);
    GLfloat vertices[] = {
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0,
        -1.0, 1.0, 0.0,
        1.0, 1.0, 0.0,
    };
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    shader->use();
    bindToUnit(GL_TEXTURE0);
    GLint loc = shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    unbind();
}

Texture3D::Texture3D(GLint internalFormat, GLenum format, GLenum type,
                     int width, int height, int depth) :
    Texture(GL_TEXTURE_3D, internalFormat, format, type),
    width(width), height(height), depth(depth) {

}

}
