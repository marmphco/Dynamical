//
//  DYOpenGLView.h
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "../../renderer/shader.h"
#include "../../renderer/texture.h"
#include "../../renderer/scene.h"
#include "../../renderer/mesh.h"
#include <list>
/*
@interface DYOpenGLView : NSOpenGLView
{
    Scene *scene;
    Shader *basicShader;
    Shader *pickShader;
    Shader *displayShader;
    Renderable *axes;
    Mesh *axesMesh;
    Texture2D *displayTexture;
    Texture2D *pickTexture;
        
    // For mouse handling
    NSPoint previousPointInView;
    int selected;
}

+ (NSOpenGLContext *)sharedContext;
- (void)redraw;

@end
*/