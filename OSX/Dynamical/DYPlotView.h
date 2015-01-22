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
#import "DYDefinitions.h"
#include <list>
#import "distributions.h"

using namespace dynam;

/**
 A view that draws paths and allows users to pick objects
 with the mouse. It knows nothing about the dynamical systems.
 */
@interface DYPlotView : DYOpenGLView
{
    Mesh *cubeMesh;
    std::list<Seed *> seeds;
    
    Shader *_distributionShader;
    Renderable *_distributionCircle;
    int _distributionCircleID;
}

@property (nonatomic, weak) IBOutlet id<DYPlotViewDelegate> delegate;

- (Seed *)addSeed;
- (void)removeSelectedSeed;

- (void)enumerateSeedsWithBlock:(void (^)(Seed *)) block;

- (void)replacePathWithID:(int)pathID
                 vertices:(GLfloat *)vertices
                  indices:(GLuint *)indices
              vertexCount:(int)vertexCount
               indexCount:(int)indexCount
                   sValue:(float)sValue;

- (void)displayClusters:(vector<dst::Cluster>)clusters;

@end
