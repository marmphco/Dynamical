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

using namespace dynam;

@interface DYOpenGLView : NSOpenGLView
{
    Scene *scene;
    Shader *flatColorShader;
    Shader *colorRampShader;
    Shader *pathShader;
    Shader *pickShader;
    Shader *displayShader;
    Renderable *axes;
    Mesh *axesMesh;
    Texture2D *displayTexture;
    Texture2D *pickTexture;
    
    Renderable *selected;

    // For mouse handling
@private
    NSPoint previousPointInView;
}

+ (NSOpenGLContext *)sharedContext;
- (void)redraw;

- (void)renderableWasSelected:(Renderable *)renderable;
- (void)renderableWasDeselected:(Renderable *)renderable;
- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination;

@end
