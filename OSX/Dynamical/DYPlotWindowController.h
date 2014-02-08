//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

#include "../../renderer/shader.h"
#include "../../renderer/texture.h"
#include "../../renderer/scene.h"
#include "../../renderer/mesh.h"

using namespace dynam;
using namespace std;

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


@interface DYPlotWindowController : NSWindowController
{
    DynamicalSystem *lorenzSystem;
    Scene *scene;
    Shader *displayShader;
    SystemModel *model;
    Mesh *mesh;
    Texture2D *displayTexture;
}

@property (assign) IBOutlet NSOpenGLView *openGLView;

@end
