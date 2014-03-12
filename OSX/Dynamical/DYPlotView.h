//
//  DYPlotView.h
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DYOpenGLView.h"
#import "DYPlotViewDelegate.h"
#include <list>

using namespace dynam;

class Seed : public Renderable {
public:
    int seedID;
    //int pathID;
    vector<int> pathIDs;
    int evolutionCount;
        
    Seed(Mesh *mesh, Shader *shader, int evolutions) :
        Renderable(mesh, shader, GL_TRIANGLES),
        pathIDs(10, 0),
        evolutionCount(evolutions){
        transform.center = Vector3(0.5, 0.5, 0.5);
    };
};

/**
 A view that draws paths and allows users to pick objects
 with the mouse. It knows nothing about the dynamical systems.
 */
@interface DYPlotView : DYOpenGLView
{
    Mesh *cubeMesh;
    std::list<Seed *> seeds;
}

@property (nonatomic, weak) IBOutlet id<DYPlotViewDelegate> delegate;

- (Seed *)addSeed;
- (void)removeSelectedSeed;

- (void)enumerateSeedsWithBlock:(void (^)(Seed *)) block;

- (void)replacePathWithID:(int)pathID
                 vertices:(GLfloat *)vertices
                  indices:(GLuint *)indices
              vertexCount:(int)vertexCount
               indexCount:(int)indexCount;


@end
