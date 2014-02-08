//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/8/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "../../renderer/shader.h"
#include "../../renderer/texture.h"
#include "../../renderer/scene.h"
#include "../../renderer/mesh.h"

using namespace dynam;

@interface DYPlotViewController : NSViewController
{
    Scene *scene;
    Shader *displayShader;
    Renderable *model;
    Mesh *mesh;
    Texture2D *displayTexture;
    
    // For mouse handling
    NSPoint previousPointInView;
}

@property (nonatomic, strong) NSOpenGLView *plotView;

- (id)initWithView:(NSOpenGLView *)view;
- (void)redraw;

- (void)replacePathWithVertices:(GLfloat *)vertices indices:(GLuint *)indices;

@end
