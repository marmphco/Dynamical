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
    scene->blendEnabled = true;
    cubeMesh = DYMakePointMesh();

}

- (Seed *)addSeed
{
    [self.openGLContext setView:self];
    GLfloat vertices[6] = {0, 0, 0, 0, 0, 0};
    GLuint indices[1] = {0};
    
    int evolutions = 20;
    Seed *seed = new Seed(cubeMesh, pickShader, evolutions);
    seed->init();
    seed->transform.center = Vector3(0.0, 0.0, 0.0);
    seed->seedID = scene->add(seed);
    
    for (int i = 0; i < evolutions; i++) {
        Mesh *mesh = new Mesh((GLfloat *)vertices, indices, 2, 1, 3);
        Path *path = new Path(mesh, pathShader, (float)i/(evolutions-1.0));
        path->setupVertexAttributes = setupVertexAttributes;
        path->setupUniforms = setupPathUniforms;
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
    
    [self.delegate plotView:self seedWasDeselected:NULL];
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
                   sValue:(float)sValue
{
    [self.openGLContext setView:self];
    Path *path = (Path *)scene->getObject(pathID);
    path->s = sValue;
    path->mesh->modifyData(vertices, indices, vertexCount, indexCount, 6);
}

- (void)renderableWasSelected:(Renderable *)renderable
{
    Seed *seed = (Seed *)renderable;
    seed->selected = true;
    [self.delegate plotView:self seedWasSelected:0];
}

- (void)renderableWasDeselected:(dynam::Renderable *)renderable
{
    if (renderable) {
        Seed *seed = (Seed *)renderable;
        seed->selected = false;
    }
    [self.delegate plotView:self seedWasDeselected:0];
}

- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination
{
    [super renderable:renderable draggedFromPoint:origin toPoint:destination];
    [self.delegate plotView:self seedWasMoved:(Seed *)renderable];
}

@end
