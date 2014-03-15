//
//  DYParameterSpaceView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYParameterSpaceView.h"

@interface DYParameterSpaceView ()

- (void)updatePath;

@end

@implementation DYParameterSpaceView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    handleMesh = DYMakePointMesh();
    pathMesh = DYMakePointMesh();
    axesConnectorMesh = DYMakePointMesh();
    
    minHandle = new Renderable(handleMesh, pickShader, GL_POINTS);
    minHandle->setupVertexAttributes = setupVertexAttributes;
    minHandle->setupUniforms = setupPointSpriteUniforms;
    minHandle->init();
    maxHandle = new Renderable(handleMesh, pickShader, GL_POINTS);
    maxHandle->setupVertexAttributes = setupVertexAttributes;
    maxHandle->setupUniforms = setupPointSpriteUniforms;
    maxHandle->init();
    
    path = new Renderable(pathMesh, colorRampShader, GL_LINES);
    path->setupVertexAttributes = setupVertexAttributes;
    path->init();
    
    axesConnectors = new Renderable(axesConnectorMesh, flatColorShader, GL_LINES);
    axesConnectors->setupVertexAttributes = setupVertexAttributes;
    axesConnectors->init();
    
    scene->add(path);
    scene->add(axesConnectors);
    scene->add(minHandle);
    scene->add(maxHandle);

}

- (void)dealloc
{
    delete handleMesh;
    delete pathMesh;
    delete minHandle;
    delete maxHandle;
    delete path;
    delete axesConnectors;
}

- (void)updatePath
{
    GLfloat vertexData[] = {
        (GLfloat)minHandle->transform.position.x,
        (GLfloat)minHandle->transform.position.y,
        (GLfloat)minHandle->transform.position.z,
        0.0, 0.0, 0.0,
        (GLfloat)maxHandle->transform.position.x,
        (GLfloat)maxHandle->transform.position.y,
        (GLfloat)maxHandle->transform.position.z,
        1.0, 1.0, 1.0
    };
    GLuint indexData[] = {0, 1};
    pathMesh->modifyData(vertexData, indexData, 2, 2, 6);
    
    GLfloat connectorVertexData[] = {
        //handle 1 position
        (GLfloat)minHandle->transform.position.x,
        (GLfloat)minHandle->transform.position.y,
        (GLfloat)minHandle->transform.position.z,
        1.0, 1.0, 1.0,
        // handle 1 x
        0.0,
        (GLfloat)minHandle->transform.position.y,
        (GLfloat)minHandle->transform.position.z,
        1.0, 1.0, 1.0,
        // handle 1 y
        (GLfloat)minHandle->transform.position.x,
        0.0,
        (GLfloat)minHandle->transform.position.z,
        1.0, 1.0, 1.0,
        // handle 1 z
        (GLfloat)minHandle->transform.position.x,
        (GLfloat)minHandle->transform.position.y,
        0.0,
        1.0, 1.0, 1.0,
        //handle 2 position
        (GLfloat)maxHandle->transform.position.x,
        (GLfloat)maxHandle->transform.position.y,
        (GLfloat)maxHandle->transform.position.z,
        1.0, 1.0, 1.0,
        // handle 2 x
        0.0,
        (GLfloat)maxHandle->transform.position.y,
        (GLfloat)maxHandle->transform.position.z,
        1.0, 1.0, 1.0,
        // handle 2 y
        (GLfloat)maxHandle->transform.position.x,
        0.0,
        (GLfloat)maxHandle->transform.position.z,
        1.0, 1.0, 1.0,
        // handle 2 z
        (GLfloat)maxHandle->transform.position.x,
        (GLfloat)maxHandle->transform.position.y,
        0.0,
        1.0, 1.0, 1.0,
    };
    GLuint connectorIndexData[] = {0, 1, 0, 2, 0, 3, 4, 5, 4, 6, 4, 7};
    axesConnectorMesh->modifyData(connectorVertexData, connectorIndexData, 2, 2, 6);
    axesConnectorMesh->modifyData(connectorVertexData, connectorIndexData, 8, 12, 6);
}

- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination
{
    [super renderable:renderable draggedFromPoint:origin toPoint:destination];
    [self updatePath];

    [self.delegate parameterSpaceViewBoundsDidChange:self];
}

- (void)setStartValue:(double)value forAxis:(int)axis
{
    switch (axis) {
        case 0:
            minHandle->transform.position.x = value;
            break;
        case 1:
            minHandle->transform.position.y = value;
            break;
        case 2:
            minHandle->transform.position.z = value;
            break;
    }
    [self updatePath];
}

- (void)setEndValue:(double)value forAxis:(int)axis {
    switch (axis) {
        case 0:
            maxHandle->transform.position.x = value;
            break;
        case 1:
            maxHandle->transform.position.y = value;
            break;
        case 2:
            maxHandle->transform.position.z = value;
            break;
    }
    [self updatePath];
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
