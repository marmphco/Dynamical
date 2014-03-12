//
//  DYPlotView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotView.h"

static void setupVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
    loc = object->shader->getAttribLocation("vVelocity");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
};

static Mesh *loadCube(float width, float height, float depth) {
    float vertexData[] = {
        0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
        width, 0.0, 0.0, 1.0, 1.0, 1.0,
        width, height, 0.0, 1.0, 1.0, 1.0,
        0.0, height, 0.0, 1.0, 1.0, 1.0,
        
        0.0, 0.0, depth, 1.0, 1.0, 1.0,
        width, 0.0, depth, 1.0, 1.0, 1.0,
        width, height, depth, 1.0, 1.0, 1.0,
        0.0, height, depth, 1.0, 1.0, 1.0
    };
    GLuint indexData[] = {
        0, 3, 1,
        3, 2, 1,
        1, 2, 5,
        2, 6, 5,
        0, 7, 3,
        0, 4, 7,
        3, 7, 2,
        7, 6, 2,
        4, 5, 7,
        7, 5, 6,
        0, 1, 4,
        1, 5, 4,
    };
    return new Mesh(vertexData, indexData, 16, 36, 3);
}

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
    
    int evolutions = 20;
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
        scene->remove(*j);
        delete scene->getObject(*j)->mesh;
        delete scene->getObject(*j);
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
    NSLog(@"update %d", pathID);
    [self.openGLContext setView:self];
    Renderable *path = scene->getObject(pathID);
    NSLog(@"%p", path);
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
