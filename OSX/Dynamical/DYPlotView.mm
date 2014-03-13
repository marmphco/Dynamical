//
//  DYPlotView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotView.h"

@implementation DYPlotView

- (void)awakeFromNib
{
    [super awakeFromNib];
    cubeMesh = loadCube(1.0, 1.0, 1.0);

}

- (Seed *)addSeed
{
    [self.openGLContext setView:self];
    GLfloat vertices[6] = {0, 0, 0, 0, 0, 0};
    GLuint indices[1] = {0};
    
    int evolutions = 10;
    Seed *seed = new Seed(cubeMesh, pickShader, evolutions);
    seed->setupVertexAttributes = setupVertexAttributes;
    seed->init();
    seed->transform.center = Vector3(0.0, 0.0, 0.0);
    seed->seedID = scene->add(seed);
    
    for (int i = 0; i < evolutions; i++) {
        Mesh *mesh = new Mesh((GLfloat *)vertices, indices, 2, 1, 3);
        Renderable *path = new Renderable(mesh, velocityColorShader, GL_LINE_STRIP);
        path->setupVertexAttributes = setupVertexAttributes;
        path->init();
        seed->pathIDs[i] = scene->add(path);
    }
    
    seeds.push_back(seed);
    return seed;
}

- (void)removeSelectedSeed
{
    std::list<Seed *>::iterator i;
    for (i = seeds.begin(); i != seeds.end();++i) {
        if (*i == selected) break;
    }
    seeds.erase(i);
    
    std::vector<int>::iterator j;
    for (j = ((Seed *)selected)->pathIDs.begin(); j < ((Seed *)selected)->pathIDs.end(); ++j) {
        delete scene->getObject(*j)->mesh;
        delete scene->getObject(*j);
        scene->remove(*j);
    }
    scene->remove(((Seed *)selected)->seedID);
    delete selected;
}

- (void)enumerateSeedsWithBlock:(void (^)(Seed *))block
{
    [self.openGLContext setView:self];
    std::list<Seed *>::iterator i;
    for (i = seeds.begin(); i != seeds.end(); ++i) {
        block(*i);
    }
}

- (void)replacePathWithID:(int)pathID
                 vertices:(GLfloat *)vertices
                  indices:(GLuint *)indices
              vertexCount:(int)vertexCount
               indexCount:(int)indexCount
{
    [self.openGLContext setView:self];
    Renderable *path = scene->getObject(pathID);
    path->mesh->modifyData((GLfloat *)vertices, indices, vertexCount, indexCount, 3);
}

- (void)renderableWasSelected:(Renderable *)renderable
{
    
}

- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination
{
    [super renderable:renderable draggedFromPoint:origin toPoint:destination];
    [self.delegate seedWasMoved:(Seed *)renderable];
}

@end
