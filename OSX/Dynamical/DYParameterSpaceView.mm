//
//  DYParameterSpaceView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYParameterSpaceView.h"

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


@implementation DYParameterSpaceView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    handleMesh = loadCube(1.0, 1.0, 1.0);
    
    minHandle = new ParameterHandle(handleMesh, pickShader);
    minHandle->setupVertexAttributes = setupVertexAttributes;
    minHandle->init();
    maxHandle = new ParameterHandle(handleMesh, pickShader);
    maxHandle->setupVertexAttributes = setupVertexAttributes;
    maxHandle->init();
    
    scene->add(minHandle);
    scene->add(maxHandle);
}

- (void)dealloc
{
    delete handleMesh;
    delete minHandle;
    delete maxHandle;
}

- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination
{
    [super renderable:renderable draggedFromPoint:origin toPoint:destination];
    [self.delegate parameterSpaceViewBoundsDidChange:self];
}

- (double)minValueForAxis:(int)axis
{
    switch (axis) {
        case 0: return minHandle->transform.position.x;
        case 1: return minHandle->transform.position.y;
        case 2: return minHandle->transform.position.z;
        default: return 0;
    }
}

- (double)maxValueForAxis:(int)axis
{
    switch (axis) {
        case 0: return maxHandle->transform.position.x;
        case 1: return maxHandle->transform.position.y;
        case 2: return maxHandle->transform.position.z;
        default: return 0;
    }
}

@end
