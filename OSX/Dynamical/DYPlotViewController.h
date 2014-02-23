//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/8/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DYPlotViewControllerDelegate.h"
#include "../../renderer/shader.h"
#include "../../renderer/texture.h"
#include "../../renderer/scene.h"
#include "../../renderer/mesh.h"
#include <list>

using namespace dynam;

class Seed : public Renderable {
public:
    int seedID;
    int pathID;
    
    Seed(Mesh *mesh, Shader *shader, int pathID) :
        Renderable(mesh, shader, GL_TRIANGLES),
        pathID(pathID) {
        transform.center = Vector3(0.5, 0.5, 0.5);
    };
};


/**
 A view that draws paths and allows users to pick objects
 with the mouse. It knows nothing about the dynamical systems.
 */
@interface DYPlotViewController : NSViewController
{
    Scene *scene;
    Shader *basicShader;
    Shader *pickShader;
    Shader *displayShader;
    Renderable *axes;
    Mesh *axesMesh;
    Mesh *cubeMesh;
    Texture2D *displayTexture;
    Texture2D *pickTexture;
    
    std::list<Seed *> seeds;
    
    // For mouse handling
    NSPoint previousPointInView;
}

@property (nonatomic, strong) NSOpenGLView *plotView;
@property (nonatomic, weak) id<DYPlotViewControllerDelegate> delegate;

- (id)initWithView:(NSOpenGLView *)view;
- (void)redraw;
- (void)viewDidResize;
- (void)setZoom:(float)zoom;

- (Seed *)addSeed;
//- (void)removeSelectedSeed;
- (void)enumerateSeedsWithBlock:(void (^)(Seed *)) block;

- (void)replacePathWithID:(int)pathID
                 vertices:(GLfloat *)vertices
                  indices:(GLuint *)indices
              vertexCount:(int)vertexCount
               indexCount:(int)indexCount;

@end
